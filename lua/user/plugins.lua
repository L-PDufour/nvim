-- lazy.nvim plugin configuration adapted from your Nix setup
require("lazy").setup({
	-- Core dependencies
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
	},
	{
		"folke/trouble.nvim",
		cmd = { "Trouble" },
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
	},
	{ "echasnovski/mini.nvim" },
	{ "nvim-tree/nvim-web-devicons" },
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
	},
	{ "folke/flash.nvim", event = "VeryLazy" },

	-- LSP and Completion
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
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
		event = "InsertEnter",
		dependencies = { "rafamadriz/friendly-snippets" },
	},
	{ "stevearc/conform.nvim", event = { "BufWritePre" }, cmd = { "ConformInfo" } },

	-- Navigation and Search
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Git Integration
	{ "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" } },
	{ "sindrets/diffview.nvim", cmd = { "DiffviewOpen", "DiffviewFileHistory" } },

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
				modules = {},
				ensure_installed = "all",
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
		"windwp/nvim-ts-autotag",
		opts = {},
	},
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
	{
		"mfussenegger/nvim-dap-python",
		dependencies = { "mfussenegger/nvim-dap" },
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
	},
}, {

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
