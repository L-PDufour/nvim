-- Plugin bootstrap for machines without Nix (e.g. OpenBSD).
--
-- On the Nix-managed Linux install the wrapper sets vim.g.nix_managed and all
-- plugins are already on the runtimepath from the store, so this module is
-- never loaded (see init.lua and lib/default.nix).
--
-- Neovim 0.12's built-in vim.pack downloads into stdpath("data")/site/pack and
-- records the resolved revisions in nvim-pack-lock.json next to init.lua.
-- { load = true } sources plugin/ and ftdetect/ immediately, which VimL plugins
-- (vim-tmux-navigator, vim-dadbod, undotree) need for their commands/mappings.

local M = {}

-- Keep this list in sync with mkNeovimPlugins in lib/default.nix.
M.plugins = {
	{ src = "https://github.com/nvim-mini/mini.nvim", version = "stable" },

	-- core
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/folke/snacks.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/folke/flash.nvim",
	"https://github.com/mbbill/undotree",
	"https://github.com/christoomey/vim-tmux-navigator",
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },

	-- treesitter (main branch installs parsers itself, see M.treesitter)
	"https://github.com/nvim-treesitter/nvim-treesitter",

	-- completion (blink.lib and friendly-snippets are runtime deps of blink.cmp)
	"https://github.com/saghen/blink.lib",
	"https://github.com/saghen/blink.cmp",
	"https://github.com/mikavilpas/blink-ripgrep.nvim",
	"https://github.com/ribru17/blink-cmp-spell",
	"https://github.com/disrupted/blink-cmp-conventional-commits",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/folke/lazydev.nvim",

	-- lint / format
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",

	-- dap
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/igorlfs/nvim-dap-view",
	"https://github.com/leoluz/nvim-dap-go",
	"https://github.com/mfussenegger/nvim-dap-python",

	-- db
	"https://github.com/tpope/vim-dadbod",
	"https://github.com/kristijanhusak/vim-dadbod-ui",
	"https://github.com/kristijanhusak/vim-dadbod-completion",

	-- ai
	"https://github.com/olimorris/codecompanion.nvim",

	-- misc
	"https://github.com/nvim-orgmode/orgmode",
	"https://github.com/lukas-reineke/headlines.nvim",
	"https://github.com/maskudo/devdocs.nvim",
	"https://github.com/stevearc/quicker.nvim",
	"https://github.com/stevearc/overseer.nvim",
}

-- Languages worth parsing eagerly; the rest are installed on demand with
-- :TSInstall. Parser builds are local (no prebuilt binaries for OpenBSD), so
-- tree-sitter CLI + a C compiler are required for this step only.
M.treesitter = {
	"bash",
	"c",
	"cpp",
	"css",
	"diff",
	"gitcommit",
	"go",
	"gomod",
	"gosum",
	"html",
	"javascript",
	"json",
	"jsonc",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"sql",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

local function parser_installed(lang)
	return pcall(vim.treesitter.language.add, lang)
end

-- Runs after vim.pack.add: nvim-treesitter ships no parsers themselves, they
-- are compiled/downloaded on first run. Missing toolchain is a warning, never
-- an error — highlighting then falls back to regex syntax.
function M.install_treesitter()
	if vim.fn.executable("tree-sitter") ~= 1 then
		vim.notify(
			"nvim-treesitter: `tree-sitter` CLI not found on PATH; parsers not installed (syntax highlighting falls back to regex)",
			vim.log.levels.WARN
		)
		return
	end

	local ok, ts = pcall(require, "nvim-treesitter")
	if not ok then
		return
	end

	local missing = {}
	for _, lang in ipairs(M.treesitter) do
		if not parser_installed(lang) then
			table.insert(missing, lang)
		end
	end
	if #missing == 0 then
		return
	end

	local installed = pcall(ts.install, missing)
	if not installed then
		vim.notify("nvim-treesitter: failed to install " .. table.concat(missing, ", "), vim.log.levels.WARN)
	end
end

function M.setup()
	-- On a fresh machine this clones everything on first start; a network
	-- hiccup should surface once instead of aborting with a raw traceback.
	local ok, err = pcall(vim.pack.add, M.plugins, { load = true })
	if not ok then
		vim.notify("vim.pack: plugin installation failed:\n" .. tostring(err), vim.log.levels.ERROR)
		return false
	end

	-- Keep startup non-blocking: parsers are only checked once nvim is idle.
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			vim.schedule(M.install_treesitter)
		end,
	})

	return true
end

return M
