-- Snacks: the primary UI layer (notifier, input, pickers, explorer, ...).
-- Anything snacks covers lives here; mini.nvim is kept only for features
-- without a snacks equivalent (see config/mini.lua).

local snacks = require("snacks")

snacks.setup({
	-- Pretty notifications + history (<Leader>en)
	notifier = {
		enabled = true,
		timeout = 3000,
	},
	-- Floating `vim.ui.input` (LSP rename, compile prompt, etc.)
	input = { enabled = true },
	-- All pickers; also takes over `vim.ui.select` (config.pick)
	picker = { enabled = true },
	-- File explorer (replaces netrw and mini.files)
	explorer = {
		enabled = true,
		replace_netrw = true,
	},
	-- Buffer deletion that keeps the window layout (MiniBufremove replacement)
	bufdelete = { enabled = true },
	-- Indent guides / scope (MiniIndentscope replacement)
	indent = { enabled = true },
	-- Persistent, per-project, per-filetype scratch buffers à la Emacs
	-- *scratch*. Content survives restarts (stored under stdpath("data")/
	-- scratch); lua scratches can be evaluated in place with <CR> (whole
	-- buffer or visual selection).
	scratch = {},
})

-- `bufdelete`, `gitbrowse`, `lazygit` and `terminal` need no setup; they are
-- plain modules configured at call time.

vim.keymap.set("n", "<Leader>bs", function()
	snacks.scratch()
end, { desc = "Scratch (persistent, current ft)" })
vim.keymap.set("n", "<Leader>bS", function()
	snacks.scratch.select()
end, { desc = "Scratch select" })
