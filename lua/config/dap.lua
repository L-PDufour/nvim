-- DAP (Debug Adapter Protocol) Configuration
-- Only adapters are declared here. Launch configurations come from each
-- project's .vscode/launch.json, which nvim-dap reads automatically
-- (:help dap-providers). nvim-dap-go and nvim-dap-python still register
-- their default configurations.

local dap = require("dap")

-- ============================================================================
-- JavaScript / TypeScript (vscode-js-debug)
-- ============================================================================
local js_debug_adapter = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "js-debug",
		args = { "${port}" },
	},
}

dap.adapters["pwa-node"] = js_debug_adapter
dap.adapters["pwa-chrome"] = js_debug_adapter
-- VS Code launch.json also uses the short names.
dap.adapters.node = js_debug_adapter
dap.adapters.chrome = js_debug_adapter

-- ============================================================================
-- C / C++ (LLVM's lldb-dap, provided by the `lldb` Nix package)
-- ============================================================================
dap.adapters.lldb = {
	type = "executable",
	command = "lldb-dap",
	name = "lldb",
}

-- ============================================================================
-- Go (delve) and Python (debugpy)
-- ============================================================================
require("dap-go").setup({
	delve = {
		path = "dlv",
		initialize_timeout_sec = 20,
		port = "${port}",
		args = {},
		build_flags = "",
		detached = vim.fn.has("win32") == 0,
	},
})
require("dap-python").setup("python")

-- ============================================================================
-- Debug UI (nvim-dap-view)
-- ============================================================================
require("dap-view").setup({
	-- keep the terminal window after the session ends so last program output
	-- is still readable ("open_term" would only ever open the terminal)
	auto_toggle = "keep_terminal",
	-- reopen the UI when switching tabs (default: it stays hidden)
	follow_tab = true,
	winbar = {
		sections = { "scopes", "watches", "repl", "breakpoints", "threads", "exceptions", "disassembly" },
		default_section = "scopes", -- there are no watches by default
		controls = { enabled = true },
	},
	windows = {
		position = "below",
		size = 0.3,
		terminal = {
			position = "left",
			size = 0.3,
			-- `hide` matches `session.config.type`, not the adapter display
			-- name: dap-go registers the adapter as `go`, lldb-dap as `lldb`.
			-- `node`/`chrome` are our aliases; nvim-dap-view only auto-hides
			-- the `pwa-*` ones. `python` keeps its terminal on purpose.
			hide = { "go", "lldb", "node", "chrome" },
		},
	},
	-- dap-view's own switchbuf for jumping to frames/breakpoints
	switchbuf = "useopen,usetab",
	virtual_text = { enabled = true, position = "eol" },
})

-- nvim-dap's jump when the program stops: reuse a visible window if there is
-- one, otherwise the first tab containing the buffer, else a new tab.
require("dap").defaults.fallback.switchbuf = "usevisible,usetab,newtab"

-- Disassembly view: a *custom* view registered by nvim-dap-disasm. It only
-- registers if `dap-view` is already loaded (it is, right above), and the
-- section is listed in `winbar.sections` above. Adapter must support the DAP
-- `disassemble` request + `instructionPointerReference` (delve, lldb-dap yes;
-- debugpy, js-debug no).
local has_disasm, disasm = pcall(require, "dap-disasm")
if has_disasm then
	disasm.setup({
		dapview_register = true,
		dapview = { keymap = "D", label = "Disassembly", short_label = "󰒓" },
	})
else
	-- until `nix flake update nvim` installs nvim-dap-disasm
	vim.notify_once("nvim-dap-disasm is not installed yet; rebuild nvim in nixcfg", vim.log.levels.INFO)
end

-- With the dap-view integration, dap-disasm disables its own winbar (the one
-- with instruction-granularity step buttons), so bind them in its buffer.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dap-disassembly",
	callback = function()
		local d = require("dap-disasm")
		vim.keymap.set("n", "<F11>", d.step_into, { buffer = true, desc = "Disassembly: step instruction into" })
		vim.keymap.set("n", "<F10>", d.step_over, { buffer = true, desc = "Disassembly: step instruction over" })
		-- only meaningful for adapters that support reverse execution
		vim.keymap.set("n", "<S-F11>", d.step_back, { buffer = true, desc = "Disassembly: step instruction back" })
	end,
})

dap.set_log_level("WARN")

-- ============================================================================
-- Breakpoint Signs
-- ============================================================================
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define(
	"DapBreakpointCondition",
	{ text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
)
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DapLogPoint", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })

-- Neither nvim-dap nor the theme defines this group, so the `linehl` above
-- used to be a no-op. DapStoppedLine is applied to the whole stopped line and
-- also by nvim-dap-disasm's PC sign.
vim.api.nvim_set_hl(0, "DapStoppedLine", { link = "Visual" })

-- ============================================================================
-- REPL Auto-complete
-- ============================================================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dap-repl",
	callback = function()
		require("dap.ext.autocompl").attach()
	end,
})
