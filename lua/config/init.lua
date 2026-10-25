-- init.lua - Bootstrap configuration
-- Assumes plugins are managed by Nix

-- Set leader keys early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Plugin bootstrap. On the Nix-wrapped install the plugins are already on the
-- runtimepath and the wrapper sets vim.g.nix_managed, so vim.pack is skipped.
-- Everywhere else (e.g. OpenBSD) vim.pack installs them from nvim-pack-lock.json.
if not vim.g.nix_managed then
	-- If the download failed, the modules below cannot load anyway; the
	-- notification from plugins.setup holds the actual error.
	if not require("plugins").setup() then
		return
	end
end

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
require("config.themes") -- Vim options
require("config.autocmds") -- Autocommands
require("config.keymaps") -- General keymaps
require("config.mini") -- All mini.nvim setup
require("config.lsp") -- LSP configuration
require("config.cmp") -- Completion setup
require("config.dap") -- DAP (debugger) setup
require("config.org")
require("config.quicker")
require("config.compile") -- Emacs-style :Compile/:Recompile (overseer)
require("config.snacks") -- Persistent scratch buffers
require("config.act") -- Embark-style act-at-point (g.)
require("config.ai") -- CodeCompanion: DeepSeek chat + opencode ACP agent
require("config.pick")
require("config.dadbod")
require("config.devdocs") -- DevDocs offline documentation
