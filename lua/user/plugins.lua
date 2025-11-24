-- mini.deps plugin configuration
-- See :h mini.deps for full documentation
-- Key concepts: :h MiniDeps.add(), :h MiniDeps.now(), :h MiniDeps.later()

local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"

-- Clone mini.nvim if not present
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up mini.deps
-- See :h MiniDeps.setup() for configuration options
require("mini.deps").setup({ path = { package = path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Core dependencies (loaded immediately)
-- See :h MiniDeps.add() for add() options like 'depends' and 'checkout'
now(function()
	add("nvim-lua/plenary.nvim")
	add("nvim-tree/nvim-web-devicons")
end)

-- Which-key for keybinding help
-- Load after UI is ready - see :h VimEnter
later(function()
	add("folke/which-key.nvim")
	-- Configure here or in separate file
	-- See :h which-key.nvim
end)

-- Trouble for diagnostics
-- See :h MiniDeps.add() - these won't load until commanded
later(function()
	add("folke/trouble.nvim")
	-- Access via :Trouble command
	-- See :h trouble.nvim
end)

-- Lazydev for Lua development
-- Only loads for .lua files - see :h FileType
	add("folke/lazydev.nvim")
	-- Auto-configures when editing Lua files
	-- See :h lazydev.nvim
-- 
-- Linting support
-- See :h MiniDeps.later() for deferred loading
	add("mfussenegger/nvim-lint")
	-- Configure linters per filetype
	-- See :h nvim-lint
-- 
-- mini.nvim modules (already have mini.deps, can use others)
-- See :h mini.nvim for full list of modules
-- Examples: mini.ai, mini.surround, mini.statusline, etc.
later(function()
	-- Add any other mini modules you want here
	-- They're part of mini.nvim, just require them:
	-- require('mini.surround').setup()
	-- See :h mini.surround
end)

-- Snacks.nvim utility collection
now(function()
	add("folke/snacks.nvim")
	-- High priority, load immediately
	-- See :h snacks.nvim
end)

-- Flash for enhanced navigation
later(function()
	add("folke/flash.nvim")
	-- Provides fast cursor movement
	-- See :h flash.nvim
end)

-- LSP and Completion
-- Load when entering insert mode - see :h InsertEnter
	add({
		source = "saghen/blink.cmp",
		checkout = "v1.*", -- Pin to v1 - see :h MiniDeps.add()
		depends = {
			"rafamadriz/friendly-snippets",
			"mikavilpas/blink-ripgrep.nvim",
		},
	})
	-- Modern completion engine
	-- See :h blink.cmp


-- LuaSnip for snippets
	add({
		source = "L3MON4D3/LuaSnip",
		depends = { "rafamadriz/friendly-snippets" },
	})
	-- Snippet engine
	-- See :h luasnip

-- conform for formatting
-- Loads before writing - see :h BufWritePre
	add("stevearc/conform.nvim")
	-- Auto-format on save
	-- See :h conform.nvim


-- harpoon for quick file navigation
later(function()
	add({
		source = "ThePrimeagen/harpoon",
		checkout = "harpoon2",
		depends = { "nvim-lua/plenary.nvim" },
	})
	-- Quick file switching
	-- See :h harpoon
end)

-- Git Integration
later(function()
	add("lewis6991/gitsigns.nvim")
	-- Git signs in the gutter
	-- See :h gitsigns.nvim
end)

later(function()
	add("sindrets/diffview.nvim")
	-- Enhanced git diffs
	-- See :h diffview.nvim
end)

-- Colorscheme (load early)
-- See :h MiniDeps.now() for immediate loading
now(function()
	add("catppuccin/nvim")
	-- Apply colorscheme
	vim.cmd.colorscheme("catppuccin")
	-- See :h catppuccin
end)

-- Treesitter for syntax highlighting
-- Load immediately for best experience
now(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		checkout = "master",
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})

	require("nvim-treesitter.configs").setup({
		ensure_installed = "all",
		sync_install = false,
		auto_install = true,
		ignore_install = { "org", "ipkg" },
		highlight = { enable = true },
		incremental_selection = { enable = true },
		indent = { enable = false },
	})
	-- See :h nvim-treesitter
end)

-- Auto-close HTML/JSX tags
later(function()
	add("windwp/nvim-ts-autotag")
	require("nvim-ts-autotag").setup()
	-- See :h nvim-ts-autotag
end)

-- Undo tree visualization
later(function()
	add("mbbill/undotree")
	-- Access via :UndotreeToggle
	-- See :h undotree
end)

-- Org-mode support
	add({
		source = "nvim-orgmode/orgmode",
		depends = { "nvim-treesitter/nvim-treesitter" },
	})
	-- Org-mode for Neovim
	-- See :h orgmode

later(function()
	add("lukas-reineke/headlines.nvim")
	-- Enhanced markdown/org headlines
	-- See :h headlines.nvim
end)

-- AI Integration
later(function()
	add("olimorris/codecompanion.nvim")
	-- AI coding assistant
	-- See :h codecompanion.nvim
end)

-- Debugger (DAP)
later(function()
	add("mfussenegger/nvim-dap")
	-- Debug Adapter Protocol
	-- See :h dap.txt
end)

later(function()
	add({
		source = "rcarriga/nvim-dap-ui",
		depends = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
	})
	-- UI for nvim-dap
	-- See :h dapui
end)

later(function()
	add({
		source = "leoluz/nvim-dap-go",
		depends = { "mfussenegger/nvim-dap" },
	})
	-- Go debugging support
	-- See :h dap-go
end)

later(function()
	add({
		source = "mxsdev/nvim-dap-vscode-js",
		depends = { "mfussenegger/nvim-dap" },
	})
	-- JavaScript/TypeScript debugging
	-- See :h dap-vscode-js
end)

-- Disable default plugins (like lazy.nvim's performance settings)
-- See :h 'runtimepath' and :h packages
vim.g.loaded_gzip = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_tutor = 1
vim.g.loaded_zipPlugin = 1

-- HELPFUL MINI.NVIM COMMANDS:
-- :h mini.deps - Main documentation
-- :h MiniDeps.add() - Add plugins
-- :h MiniDeps.update() - Update all plugins
-- :h MiniDeps.clean() - Remove unused plugins
-- :h MiniDeps.snap_save() - Save plugin versions
-- :h MiniDeps.snap_load() - Load saved versions
--
-- USEFUL MINI MODULES TO EXPLORE:
-- :h mini.ai - Extended text objects
-- :h mini.surround - Surround text objects
-- :h mini.comment - Better commenting
-- :h mini.pairs - Auto-close pairs
-- :h mini.statusline - Minimal statusline
-- :h mini.tabline - Minimal tabline
-- :h mini.files - File explorer
-- :h mini.pick - Fuzzy finder
-- :h mini.git - Git integration
-- :h mini.diff - Diff visualization
-- :h mini.completion - Simple completion
--
-- See full list: :h mini.nvim-modules
