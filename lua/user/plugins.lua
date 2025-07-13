-- lazy.nvim plugin configuration adapted from your Nix setup
require("lazy").setup({
	-- Core dependencies
	{ "nvim-lua/plenary.nvim" },
	{ "folke/which-key.nvim" },
	{ "folke/trouble.nvim" },
	{ "folke/lazydev.nvim" },
	{ "mfussenegger/nvim-lint" },
	{ "yioneko/nvim-vtsls" },
	{ "echasnovski/mini.nvim" },
	{ "max397574/better-escape.nvim" },
	{ "nvim-tree/nvim-web-devicons" },
	{ "folke/snacks.nvim" },
	{ "folke/flash.nvim" },

	-- LSP and Completion
	{
		"saghen/blink.cmp",
		dependencies = {
			"rafamadriz/friendly-snippets",
			{
				"mikavilpas/blink-ripgrep.nvim",
				version = "*", -- use the latest stable version
			},
		},
		version = "1.*",
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = { "rafamadriz/friendly-snippets" },
	},
	{ "stevearc/conform.nvim" },

	-- Navigation and Search
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Git Integration
	{ "lewis6991/gitsigns.nvim" },
	{ "sindrets/diffview.nvim" },

	-- UI and Aesthetics
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000, -- load colorscheme early
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = "all", -- equivalent to withAllGrammars
				sync_install = false,
				auto_install = true,
				ignore_install = { "org", "ipkg" },
				highlight = { enable = true },
				incremental_selection = { enable = true },
				indent = { enable = false },
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	-- Productivity Tools
	{ "mbbill/undotree" },
	{
		"nvim-orgmode/orgmode",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	{ "lukas-reineke/headlines.nvim" },

	-- AI
	-- {
	-- 	"Davidyz/VectorCode",
	-- 	version = "*", -- optional, depending on whether you're on nightly or release
	-- 	dependencies = { "nvim-lua/plenary.nvim" },
	-- 	config = function()
	-- 		require("vectorcode").setup()
	-- 	end,
	-- },
	{ "olimorris/codecompanion.nvim" },
	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		build = "bundled_build.lua", -- Bundles `mcp-hub` binary along with the neovim plugin
		config = function()
			require("mcphub").setup({
				use_bundled_binary = true, -- Use local `mcp-hub` binary
			})
		end,
	},
	-- Debugger
	{ "mfussenegger/nvim-dap" },
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	},
	{
		"leoluz/nvim-dap-go",
		dependencies = { "mfussenegger/nvim-dap" },
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		dependencies = { "mfussenegger/nvim-dap" },
	},
}, {
	-- Lazy.nvim configuration options
	defaults = {
		lazy = false, -- don't lazy load by default (similar to Nix behavior)
	},
	install = {
		missing = true, -- install missing plugins on startup
	},
	checker = {
		enabled = true, -- check for plugin updates
		frequency = 3600, -- check every hour
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
