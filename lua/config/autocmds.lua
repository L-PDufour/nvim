-- lua/config/autocmds.lua
-- Autocommands for various behaviors

-- ============================================================================
-- HIGHLIGHT ON YANK
-- ============================================================================
Config.autocmd("TextYankPost", nil, function()
	vim.highlight.on_yank({ timeout = 200 })
end, "Highlight yanked text")

-- ============================================================================
-- FORMAT OPTIONS
-- ============================================================================
-- Remove auto-commenting and auto-inserting comment leader on 'o'
Config.autocmd("FileType", nil, function()
	vim.opt_local.formatoptions:remove({ "c", "r", "o" })
end, "Fix formatoptions")

-- ============================================================================
-- TERMINAL
-- ============================================================================
-- Start in insert mode when entering terminal
Config.autocmd("TermOpen", nil, function()
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.opt_local.signcolumn = "no"
	vim.cmd("startinsert")
end, "Terminal settings")

-- ============================================================================
-- HELP & MAN PAGES
-- ============================================================================
-- Open help and man pages in vertical split
Config.autocmd("FileType", { "help", "man" }, function()
	vim.cmd("wincmd L")
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
end, "Help/Man in vertical split")

-- ============================================================================
-- RESIZE SPLITS
-- ============================================================================
-- Automatically resize splits when window is resized
Config.autocmd("VimResized", nil, function()
	vim.cmd("tabdo wincmd =")
end, "Resize splits on window resize")

-- ============================================================================
-- AUTO-CREATE DIRECTORIES
-- ============================================================================
-- Create missing directories when saving a file
Config.autocmd("BufWritePre", nil, function(event)
	if event.match:match("^%w%w+:[\\/][\\/]") then
		return -- Don't create directories for URLs
	end
	local file = vim.uv.fs_realpath(event.match) or event.match
	vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
end, "Auto-create directories")

-- ============================================================================
-- CLOSE WITH Q
-- ============================================================================
-- Close certain filetypes with 'q'
Config.autocmd("FileType", {
	"help",
	"man",
	"qf",
	"query",
	"scratch",
	"notify",
}, function(event)
	vim.bo[event.buf].buflisted = false
	vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
end, "Close with q")

-- ============================================================================
-- DISABLE CERTAIN FEATURES FOR LARGE FILES
-- ============================================================================
Config.autocmd("BufReadPre", nil, function(event)
	local ok, stats = pcall(vim.uv.fs_stat, event.match)
	if ok and stats and stats.size > 1024 * 1024 then -- 1MB
		vim.b.large_file = true
		vim.opt_local.spell = false
		vim.opt_local.swapfile = false
		vim.opt_local.undofile = false
		vim.opt_local.breakindent = false
		vim.opt_local.colorcolumn = ""
		vim.opt_local.statuscolumn = ""
		vim.opt_local.signcolumn = "no"
		vim.opt_local.foldcolumn = "0"
		vim.opt_local.winbar = ""
		-- Disable syntax highlighting for very large files
		if stats.size > 1024 * 1024 * 2 then -- 2MB
			vim.cmd("syntax off")
		end
	end
end, "Optimize for large files")

-- ============================================================================
-- CURSOR POSITION
-- ============================================================================
-- Remember cursor position (handled by mini.misc, but here's the fallback)
-- This is already done by MiniMisc.setup_restore_cursor() in mini.lua

-- ============================================================================
-- CHECK IF FILE CHANGED OUTSIDE OF VIM
-- ============================================================================
Config.autocmd({ "FocusGained", "TermClose", "TermLeave" }, nil, function()
	if vim.o.buftype ~= "nofile" then
		vim.cmd("checktime")
	end
end, "Check for file changes")

-- ============================================================================
-- QUICKFIX
-- ============================================================================
-- Open quickfix window automatically
Config.autocmd("QuickFixCmdPost", "[^l]*", function()
	vim.cmd("cwindow")
end, "Open quickfix automatically")

Config.autocmd("QuickFixCmdPost", "l*", function()
	vim.cmd("lwindow")
end, "Open location list automatically")

-- ============================================================================
-- PROJECT-SPECIFIC CONFIGURATION
-- ============================================================================
-- Load project-specific config if available
-- Create a .nvim.lua file in your project root with custom settings
Config.autocmd({ "VimEnter", "DirChanged" }, nil, function()
	local project_config = vim.fn.getcwd() .. "/.nvim.lua"
	if vim.fn.filereadable(project_config) == 1 then
		vim.notify("Loading project config: " .. project_config, vim.log.levels.INFO)
		dofile(project_config)
	end
end, "Load project-specific configuration")

-- ============================================================================
-- TRIM TRAILING WHITESPACE
-- ============================================================================
-- This is handled by mini.trailspace, but you can auto-trim on save:
-- Uncomment if you want automatic trimming
Config.autocmd("BufWritePre", nil, function()
	-- Save cursor position
	local cursor = vim.api.nvim_win_get_cursor(0)
	-- Trim trailing whitespace
	vim.cmd([[%s/\s\+$//e]])
	-- Restore cursor position
	vim.api.nvim_win_set_cursor(0, cursor)
end, "Trim trailing whitespace on save")
