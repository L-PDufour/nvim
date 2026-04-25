vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap mini.nvim
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.uv.fs_stat(mini_path) then
	vim.cmd('echo "Installing mini.nvim..." | redraw')
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	})
	vim.cmd("packadd mini.nvim | helptags ALL")
end

require("mini.deps").setup({ path = { package = path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Colorscheme
add("catppuccin/nvim")

-- UI & navigation
add("folke/flash.nvim")
add("folke/which-key.nvim")
add("christoomey/vim-tmux-navigator")
add("mbbill/undotree")

-- Completion & LSP tooling
add({ source = "saghen/blink.cmp", depends = { "rafamadriz/friendly-snippets" } })
add("stevearc/conform.nvim")
add("mfussenegger/nvim-lint")
add("folke/lazydev.nvim")
add("mikavilpas/blink-ripgrep.nvim")

-- DAP (nvim-dap-ui depends on nvim-dap and nvim-nio)
add({ source = "rcarriga/nvim-dap-ui", depends = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } })
add("theHamsta/nvim-dap-virtual-text")
add("leoluz/nvim-dap-go")
add("mfussenegger/nvim-dap-python")

-- Other tools
add("nvim-orgmode/orgmode")
add("stevearc/overseer.nvim")
add("stevearc/oil.nvim")
add("stevearc/quicker.nvim")
add("ibhagwan/fzf-lua")
add("tpope/vim-dadbod")
add("kristijanhusak/vim-dadbod-ui")
add("kristijanhusak/vim-dadbod-completion")

-- Global config table (must be set before config modules are loaded)
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

-- Immediate: options, appearance, core plugins (needed before first draw)
now(function() require("config.options") end)
now(function() require("config.themes") end)
now(function() require("config.autocmds") end)
now(function() require("config.mini") end)
now(function() require("config.lsp") end)
now(function() require("config.cmp") end)

-- Deferred: loaded after VimEnter in declaration order
-- keymaps must follow dap (it requires dap/dapui/dap-go at load time)
later(function() require("config.dap") end)
later(function() require("config.keymaps") end)
later(function() require("config.org") end)
later(function() require("config.quicker") end)
later(function() require("config.fzf") end)
later(function() require("config.dadbod") end)
