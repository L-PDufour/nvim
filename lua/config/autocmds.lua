-- Modern autocommand groups
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
-- Autocommands ===============================================================

-- Don't auto-wrap comments and don't insert comment leader after hitting 'o'.
-- Do on `FileType` to always override these changes from filetype plugins.
local f = function()
	vim.cmd("setlocal formatoptions-=c formatoptions-=o")
end
_G.Config.new_autocmd("FileType", nil, f, "Proper 'formatoptions'")
-- Format options
local format_group = augroup("FormatOptions", { clear = true })
autocmd("FileType", {
	group = format_group,
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "o" })
	end,
	desc = "Proper formatoptions",
})

-- Highlight on yank
local yank_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	group = yank_group,
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
	desc = "Highlight yanked text",
})
