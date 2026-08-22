-- Snacks: only the scratch module for now — persistent, per-project,
-- per-filetype scratch buffers à la Emacs *scratch*. Content survives
-- restarts (stored under stdpath("data")/scratch); lua scratches can be
-- evaluated in place with <CR> (whole buffer or visual selection), which
-- is the closest nvim gets to eval-ing sexps in *scratch*.
local snacks = require("snacks")
snacks.setup({
	scratch = {},
})

vim.keymap.set("n", "<Leader>bs", function()
	snacks.scratch()
end, { desc = "Scratch (persistent, current ft)" })
vim.keymap.set("n", "<Leader>bS", function()
	snacks.scratch.select()
end, { desc = "Scratch select" })
