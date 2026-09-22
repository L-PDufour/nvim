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
	auto_toggle = true,
	winbar = {
		controls = { enabled = true },
	},
	windows = { position = "below", size = 0.3 },
	virtual_text = { enabled = true, position = "eol" },
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

-- ============================================================================
-- REPL Auto-complete
-- ============================================================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dap-repl",
	callback = function()
		require("dap.ext.autocompl").attach()
	end,
})
