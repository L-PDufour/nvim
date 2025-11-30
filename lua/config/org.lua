require("orgmode").setup({
	org_agenda_files = { "~/Sync/org/**/**" },
	org_default_notes_file = "~/Sync/org/refile.org",
	win_split_mode = "auto",
	-- Emacs-like keybindings
	mappings = {
		global = {
			org_agenda = "<leader>oa",
			org_capture = "<leader>oc",
		},
	},
	org_capture_templates = {
		t = {
			description = "Todo",
			template = "* TODO %?\n  %u",
			target = "~/Sync/org/todos.org",
		},
		j = {
			description = "Journal",
			template = "* %<%Y-%m-%d> %?\n",
			target = "~/Sync/org/journal.org",
		},
	},
})
require("headlines").setup()
