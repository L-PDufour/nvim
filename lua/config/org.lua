-- Org: the language server does the work (lib/org-lsp.nix builds it, the
-- plugin puts it on PATH). Options here are Org's variables, the same ones
-- Emacs uses, so `~/.config/org-lsp/config.toml` can hold them too.
require("org-lsp").setup({
	settings = {
		org_agenda_files = { "~/Sync/org/**/**" },
		org_default_notes_file = "~/Sync/org/refile.org",
		org_capture_templates = {
			{
				key = "t",
				description = "Todo",
				target = { "file", "~/Sync/org/todos.org" },
				template = "* TODO %?\n  %u",
			},
			{
				key = "j",
				description = "Journal",
				target = { "file", "~/Sync/org/journal.org" },
				template = "* %<%Y-%m-%d> %?\n",
			},
		},
	},
	win_split_mode = "split",
})

-- No `vim.lsp.enable("org")`: that was orgmode.nvim's own server. The plugin
-- registers and starts its `org_lsp` client on the first Org file.

-- require("headlines").setup()
