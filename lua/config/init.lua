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

	-- Leader group info shared with which-key (see config/mini.lua)
	leader_groups = {},
}

-- Load configuration modules in order
require("config.options") -- Vim options
require("config.themes") -- Vim options
require("config.snacks") -- Snacks UI layer (picker, notifier, input, explorer)
require("config.autocmds") -- Autocommands
require("config.keymaps") -- General keymaps
require("config.mini") -- Remaining mini.nvim modules
require("config.lsp") -- LSP configuration
require("config.cmp") -- Completion setup
require("config.dap") -- DAP (debugger) setup
require("config.org")
require("config.quicker")
require("config.compile") -- Emacs-style :Compile/:Recompile (overseer)
require("config.act") -- Embark-style act-at-point (g.)
require("config.ai") -- CodeCompanion: DeepSeek chat + opencode ACP agent
require("config.pick") -- Snacks picker keymaps
require("config.dadbod")
require("config.devdocs") -- DevDocs offline documentation
