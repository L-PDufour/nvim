vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- vim.pack is built into Neovim 0.12 — no bootstrap needed.
-- { load = true } sources plugin/* and ftdetect/* immediately (required for
-- VimL plugins like vim-tmux-navigator and vim-dadbod that define commands
-- and mappings in those files).
vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.nvim", version = "stable" },

	-- Colorscheme
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },

	-- UI & navigation
	"https://github.com/folke/flash.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/mbbill/undotree",

	-- Completion (friendly-snippets is a runtime dep of blink.cmp)
	"https://github.com/rafamadriz/friendly-snippets",
	{ src = "https://github.com/saghen/blink.cmp", version = "v1" },
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	"https://github.com/folke/lazydev.nvim",
	"https://github.com/mikavilpas/blink-ripgrep.nvim",

	-- DAP (nvim-nio must precede nvim-dap-ui)
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/theHamsta/nvim-dap-virtual-text",
	"https://github.com/leoluz/nvim-dap-go",
	"https://github.com/mfussenegger/nvim-dap-python",

	-- Other tools
	"https://github.com/nvim-orgmode/orgmode",
	"https://github.com/stevearc/overseer.nvim",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/stevearc/quicker.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/tpope/vim-dadbod",
	"https://github.com/kristijanhusak/vim-dadbod-ui",
	"https://github.com/kristijanhusak/vim-dadbod-completion",
}, { load = true })

-- Create global config table for sharing data between modules
_G.Config = {
	autocmd_group = vim.api.nvim_create_augroup("ConfigGroup", { clear = true }),

	autocmd = function(event, pattern, callback, desc)
		vim.api.nvim_create_autocmd(event, {
			group = _G.Config.autocmd_group,
			pattern = pattern,
			callback = callback,
			desc = desc,
		})
	end,

	leader_groups = {},
}

-- Load configuration modules in order
require("config.options")
require("config.themes")
require("config.autocmds")
require("config.keymaps")
require("config.mini")
require("config.lsp")
require("config.cmp")
require("config.dap")
require("config.org")
require("config.quicker")
require("config.fzf")
require("config.dadbod")
