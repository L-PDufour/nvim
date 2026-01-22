-- init.lua - Bootstrap configuration
-- Assumes plugins are managed by Nix

-- Set leader keys early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Create global config table for sharing data between modules
_G.Config = {
	-- Helper for creating autocommands with consistent group
	autocmd_group = vim.api.nvim_create_augroup("ConfigGroup", { clear = true }),

	autocmd = function(event, pattern, callback, desc)
		vim.api.nvim_create_autocmd(event, {
			group = _G.Config.autocmd_group,
			pattern = pattern,
			callback = callback,
			desc = desc,
		})
	end,

	-- Store leader group info for mini.clue
	leader_groups = {},
}

-- Load configuration modules in order
require("config.options") -- Vim options
require("config.autocmds") -- Autocommands
require("config.keymaps") -- General keymaps
require("config.mini") -- All mini.nvim setup
require("config.lsp") -- LSP configuration
require("config.cmp") -- Completion setup
require("config.dap") -- DAP (debugger) setup
require("config.org")
