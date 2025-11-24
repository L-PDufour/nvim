-- mini.lua - Core mini.nvim setup replacing snacks.nvim
-- See :h mini.nvim for overview of all modules

-- ============================================================================
-- CORE UI & EDITING
-- ============================================================================

-- Enhanced statusline
-- See :h mini.statusline
require("mini.statusline").setup()

-- Advanced text objects
-- See :h mini.ai for all text objects and custom patterns
local ai = require("mini.ai")
ai.setup({
	n_lines = 500,
	custom_textobjects = {
		o = ai.gen_spec.treesitter({ -- code block
			a = { "@block.outer", "@conditional.outer", "@loop.outer" },
			i = { "@block.inner", "@conditional.inner", "@loop.inner" },
		}),
		f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
		c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
		t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
		d = { "%f[%d]%d+" }, -- digits
		e = { -- Word with case
			{ "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
			"^().*()$",
		},
		u = ai.gen_spec.function_call(), -- u for "Usage"
		U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
	},
})

-- Surround operations (ys, ds, cs)
-- See :h mini.surround
require("mini.surround").setup()

-- Navigate with [ and ] (buffers, files, quickfix, etc.)
-- See :h mini.bracketed
require("mini.bracketed").setup()

-- Auto-pair brackets and quotes
-- See :h mini.pairs
require("mini.pairs").setup()

-- ============================================================================
-- FUZZY FINDER & FILE NAVIGATION (replaces Snacks.picker)
-- ============================================================================

-- Setup mini.pick for fuzzy finding
-- See :h mini.pick for all pickers and configuration
local pick = require("mini.pick")
pick.setup({
	-- Use default mappings: <C-n>/<C-p> to navigate, <CR> to select
	-- See :h MiniPick-examples for custom mappings
})

-- Setup mini.extra for additional pickers
-- See :h mini.extra for all available pickers
require("mini.extra").setup()

-- Helper function for keymaps
local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true, noremap = true })
end

-- ============================================================================
-- PICKER KEYMAPS (replacing Snacks.picker.*)
-- See :h mini.pick-builtin and :h mini.extra
-- ============================================================================

-- Top-level pickers
map("n", "<leader><space>", function()
	-- Try git files first, fallback to all files
	-- See :h MiniExtra.pickers.git_files()
	local ok = pcall(MiniExtra.pickers.git_files)
	if not ok then
		MiniPick.builtin.files()
	end
end, "Smart Find Files")

map("n", "<leader>,", function()
	MiniPick.builtin.buffers()
end, "Buffers")

map("n", "<leader>/", function()
	MiniPick.builtin.grep_live()
end, "Grep (live)")

map("n", "<leader>:", function()
	MiniExtra.pickers.history({ scope = ":" })
end, "Command History")

map("n", "<leader>n", function()
	-- For notifications, you'd need mini.notify or use :messages
	vim.cmd("messages")
end, "Show Messages")

-- File explorer (replacing Snacks.explorer)
-- See :h mini.files
map("n", "<leader>e", function()
	require("mini.files").open()
end, "File Explorer")

-- Find operations
map("n", "<leader>fb", function()
	MiniPick.builtin.buffers()
end, "Buffers")

map("n", "<leader>ff", function()
	MiniPick.builtin.files()
end, "Find Files")

map("n", "<leader>fg", function()
	MiniExtra.pickers.git_files()
end, "Find Git Files")

map("n", "<leader>fr", function()
	MiniExtra.pickers.oldfiles()
end, "Recent Files")

map("n", "<leader>fo", function()
	MiniPick.builtin.files({}, { source = { cwd = vim.fn.expand("~/Sync") } })
end, "Find Org Files")

-- Grep operations
map("n", "<leader>sb", function()
	MiniExtra.pickers.buf_lines()
end, "Buffer Lines")

map("n", "<leader>sg", function()
	MiniPick.builtin.grep_live()
end, "Grep (live)")

map({ "n", "x" }, "<leader>sw", function()
	-- Get word under cursor or visual selection
	local word = vim.fn.expand("<cword>")
	MiniPick.builtin.grep({ pattern = word })
end, "Grep word under cursor")

-- Search operations
map("n", '<leader>s"', function()
	MiniExtra.pickers.registers()
end, "Registers")

map("n", "<leader>s/", function()
	MiniExtra.pickers.history({ scope = "/" })
end, "Search History")

map("n", "<leader>sc", function()
	MiniExtra.pickers.history({ scope = ":" })
end, "Command History")

map("n", "<leader>ssC", function()
	MiniExtra.pickers.commands()
end, "Commands")

map("n", "<leader>sd", function()
	MiniExtra.pickers.diagnostic({ scope = "all" })
end, "Diagnostics")

map("n", "<leader>sD", function()
	MiniExtra.pickers.diagnostic({ scope = "current" })
end, "Buffer Diagnostics")

map("n", "<leader>ssh", function()
	MiniPick.builtin.help()
end, "Help Pages")

map("n", "<leader>ssH", function()
	MiniExtra.pickers.hl_groups()
end, "Highlight Groups")

map("n", "<leader>sj", function()
	-- Jumps aren't directly available, but you can use :jumps
	vim.cmd("jumps")
end, "Jumps")

map("n", "<leader>ssk", function()
	MiniExtra.pickers.keymaps()
end, "Keymaps")

map("n", "<leader>sl", function()
	MiniExtra.pickers.list({ scope = "location" })
end, "Location List")

map("n", "<leader>sm", function()
	MiniExtra.pickers.marks()
end, "Marks")

map("n", "<leader>ssM", function()
	-- Man pages require external tool
	vim.cmd("Man")
end, "Man Pages")

map("n", "<leader>sp", function()
	MiniExtra.pickers.pickers()
end, "Search for Pickers")

map("n", "<leader>sq", function()
	MiniExtra.pickers.list({ scope = "quickfix" })
end, "Quickfix List")

map("n", "<leader>sR", function()
	MiniPick.builtin.resume()
end, "Resume Last Picker")

map("n", "<leader>uC", function()
	-- Colorscheme picker
	vim.ui.select(vim.fn.getcompletion("", "color"), {
		prompt = "Select colorscheme:",
	}, function(choice)
		if choice then
			vim.cmd.colorscheme(choice)
		end
	end)
end, "Colorschemes")

-- ============================================================================
-- LSP PICKERS (replacing Snacks.picker.lsp_*)
-- See :h mini.extra and :h MiniExtra.pickers.lsp
-- ============================================================================

map("n", "gd", function()
	MiniExtra.pickers.lsp({ scope = "definition" })
end, "Goto Definition")

map("n", "gD", function()
	MiniExtra.pickers.lsp({ scope = "declaration" })
end, "Goto Declaration")

map("n", "grr", function()
	MiniExtra.pickers.lsp({ scope = "references" })
end, "Goto References")

map("n", "gri", function()
	MiniExtra.pickers.lsp({ scope = "implementation" })
end, "Goto Implementation")

map("n", "gy", function()
	MiniExtra.pickers.lsp({ scope = "type_definition" })
end, "Goto Type Definition")

map("n", "<leader>ss", function()
	MiniExtra.pickers.lsp({ scope = "document_symbol" })
end, "LSP Document Symbols")

map("n", "<leader>sS", function()
	MiniExtra.pickers.lsp({ scope = "workspace_symbol" })
end, "LSP Workspace Symbols")

-- ============================================================================
-- BUFFER MANAGEMENT (replacing Snacks.bufdelete)
-- See :h mini.bufremove
-- ============================================================================

require("mini.bufremove").setup()

map("n", "<leader>bd", function()
	MiniBufremove.delete()
end, "Delete Buffer")

-- ============================================================================
-- TERMINAL (replacing Snacks.terminal)
-- Use mini.nvim's built-in terminal or a simple toggle
-- ============================================================================

-- Simple terminal toggle (you can enhance this)
local term_buf = nil
local term_win = nil

local function toggle_terminal()
	if term_win and vim.api.nvim_win_is_valid(term_win) then
		vim.api.nvim_win_hide(term_win)
		term_win = nil
	else
		if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
			term_buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_call(term_buf, function()
				vim.fn.termopen(vim.o.shell)
			end)
		end
		term_win = vim.api.nvim_open_win(term_buf, true, {
			relative = "editor",
			width = math.floor(vim.o.columns * 0.9),
			height = math.floor(vim.o.lines * 0.9),
			col = math.floor(vim.o.columns * 0.05),
			row = math.floor(vim.o.lines * 0.05),
			style = "minimal",
			border = "rounded",
		})
		vim.cmd("startinsert")
	end
end

map("n", "<c-/>", toggle_terminal, "Toggle Terminal")
map("t", "<c-/>", toggle_terminal, "Toggle Terminal")

-- ============================================================================
-- NOTIFICATIONS (replacing Snacks.notifier)
-- See :h mini.notify
-- ============================================================================

require("mini.notify").setup({
	-- Window config
	window = {
		config = {
			border = "rounded",
		},
		max_width_share = 0.382,
		winblend = 25,
	},
})

-- Override vim.notify to use mini.notify
-- See :h MiniNotify.make_notify()
vim.notify = require("mini.notify").make_notify()

map("n", "<leader>un", function()
	require("mini.notify").clear()
end, "Dismiss All Notifications")

-- ============================================================================
-- FILE EXPLORER (replacing Snacks.explorer)
-- See :h mini.files
-- ============================================================================

require("mini.files").setup({
	-- See :h MiniFiles.config for all options
	windows = {
		preview = true,
		width_preview = 50,
	},
})

-- ============================================================================
-- OTHER UTILITIES
-- ============================================================================

-- Starter/Dashboard (replacing Snacks.dashboard)
-- See :h mini.starter
require("mini.starter").setup({
	header = table.concat({
		"",
		"   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  ",
		"   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  ",
		"   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  ",
		"   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  ",
		"   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  ",
		"   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  ",
		"",
	}, "\n"),
})

-- Enhanced commenting (better than default gc)
-- See :h mini.comment
require("mini.comment").setup()

-- Highlight word under cursor
-- See :h mini.cursorword
require("mini.cursorword").setup()

-- Indent guides
-- See :h mini.indentscope
require("mini.indentscope").setup({
	symbol = "│",
	options = { try_as_border = true },
})

-- Animated scrolling (replacing Snacks.scroll)
-- See :h mini.animate
require("mini.animate").setup({
	scroll = {
		enable = true,
	},
})

-- Scratch buffers (replacing Snacks.scratch)
-- This is a simple implementation, see :h scratch-buffer for concepts
local scratch_buf = nil
local function toggle_scratch()
	if scratch_buf and vim.api.nvim_buf_is_valid(scratch_buf) then
		local wins = vim.fn.win_findbuf(scratch_buf)
		if #wins > 0 then
			vim.api.nvim_win_close(wins[1], false)
			return
		end
	end

	if not scratch_buf or not vim.api.nvim_buf_is_valid(scratch_buf) then
		scratch_buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(scratch_buf, "buftype", "nofile")
		vim.api.nvim_buf_set_option(scratch_buf, "bufhidden", "hide")
	end

	vim.api.nvim_open_win(scratch_buf, true, {
		relative = "editor",
		width = math.floor(vim.o.columns * 0.8),
		height = math.floor(vim.o.lines * 0.8),
		col = math.floor(vim.o.columns * 0.1),
		row = math.floor(vim.o.lines * 0.1),
		style = "minimal",
		border = "rounded",
	})
end

map("n", "<leader>.", toggle_scratch, "Toggle Scratch Buffer")

-- ============================================================================
-- TOGGLES (replacing Snacks.toggle.*)
-- See :h mini.basics for some toggle utilities
-- ============================================================================

-- Toggle functions
local function toggle_option(option, on_val, off_val)
	on_val = on_val or true
	off_val = off_val or false
	return function()
		vim.opt[option] = vim.opt[option]:get() == off_val and on_val or off_val
		vim.notify(option .. " = " .. tostring(vim.opt[option]:get()), vim.log.levels.INFO)
	end
end

map("n", "<leader>us", toggle_option("spell"), "Toggle Spelling")
map("n", "<leader>uw", toggle_option("wrap"), "Toggle Wrap")
map("n", "<leader>uL", toggle_option("relativenumber"), "Toggle Relative Number")
map("n", "<leader>ul", toggle_option("number"), "Toggle Line Numbers")
map("n", "<leader>uc", toggle_option("conceallevel", 2, 0), "Toggle Conceal")
map("n", "<leader>ub", toggle_option("background", "dark", "light"), "Toggle Dark Background")

-- Toggle diagnostics
map("n", "<leader>ud", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
	vim.notify("Diagnostics " .. (vim.diagnostic.is_enabled() and "enabled" or "disabled"), vim.log.levels.INFO)
end, "Toggle Diagnostics")

-- Toggle treesitter highlight
map("n", "<leader>uT", function()
	vim.cmd("TSToggle highlight")
end, "Toggle Treesitter")

-- Toggle inlay hints
map("n", "<leader>uh", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
	vim.notify("Inlay hints " .. (vim.lsp.inlay_hint.is_enabled() and "enabled" or "disabled"), vim.log.levels.INFO)
end, "Toggle Inlay Hints")

-- ============================================================================
-- OTHER USEFUL KEYMAPS
-- ============================================================================

map("n", "K", vim.lsp.buf.hover, "Hover Documentation")

map("n", "<leader>N", function()
	vim.cmd("help news")
end, "Neovim News")

-- ============================================================================
-- DEBUGGING UTILITIES (replacing Snacks.debug)
-- ============================================================================

-- Simple debug print function
_G.dd = function(...)
	local objects = vim.tbl_map(vim.inspect, { ... })
	print(unpack(objects))
	return ...
end

_G.bt = function()
	print(debug.traceback())
end

vim.print = _G.dd -- Override print to use custom dd

-- ============================================================================
-- ADDITIONAL MINI MODULES TO EXPLORE
-- ============================================================================

-- See :h mini.nvim-modules for full list:
-- - :h mini.align - Align text interactively
-- - :h mini.clue - Show next key clues
-- - :h mini.colors - Color scheme utilities
-- - :h mini.completion - Simple completion
-- - :h mini.doc - Generate documentation
-- - :h mini.fuzzy - Fuzzy matching
-- - :h mini.hipatterns - Highlight patterns
-- - :h mini.hues - Generate color schemes
-- - :h mini.icons - Icon provider
-- - :h mini.jump - Jump to next/previous
-- - :h mini.jump2d - Jump to any location
-- - :h mini.map - Window with buffer text overview
-- - :h mini.misc - Miscellaneous utilities
-- - :h mini.move - Move text in any direction
-- - :h mini.operators - Text edit operators
-- - :h mini.sessions - Session management
-- - :h mini.splitjoin - Split/join arguments
-- - :h mini.tabline - Minimal tabline
-- - :h mini.test - Test Neovim plugins
-- - :h mini.trailspace - Trailing whitespace
-- - :h mini.visits - Track and reuse visits
