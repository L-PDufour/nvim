-- Git integration using mini.git and mini.diff
-- See :h mini.git and :h mini.diff for full documentation

-- Setup mini.git for git command integration
-- See :h mini.git.setup() for configuration options
-- Provides :Git command and git-related functions
require("mini.git").setup()

-- Setup mini.diff for visual git change indicators
-- See :h mini.diff.setup() for all options
require("mini.diff").setup({
	view = {
		style = "sign", -- Show changes in sign column
		-- See :h MiniDiff-view for other styles like 'number'
		signs = {
			add = "+",
			change = "~",
			delete = "_",
		},
	},
	-- Default mappings for diff operations
	-- See :h MiniDiff-mappings
	mappings = {
		-- Apply/reset hunks
		apply = "gh", -- Apply hunk under cursor
		reset = "gH", -- Reset hunk under cursor

		-- Text object for operating on hunks
		-- Use with operators: dgh (delete hunk), ygh (yank hunk)
		textobject = "gh",

		-- Hunk navigation
		-- See :h MiniDiff.goto_hunk()
		goto_first = "[H", -- Go to first hunk in buffer
		goto_prev = "[h", -- Go to previous hunk
		goto_next = "]h", -- Go to next hunk
		goto_last = "]H", -- Go to last hunk in buffer
	},
})

-- Custom keymaps for enhanced git workflow
-- See :h vim.keymap.set()
local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- Git hunk navigation compatible with diff mode
-- See :h MiniDiff.goto_hunk() and :h diff-mode
map("n", "]c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	else
		require("mini.diff").goto_hunk("next")
	end
end, "Jump to next git [c]hange")

map("n", "[c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		require("mini.diff").goto_hunk("prev")
	end
end, "Jump to previous git [c]hange")

-- Show git range history (similar to staging interface)
-- See :h MiniGit.show_range_history()
map("n", "<leader>gs", function()
	require("mini.git").show_range_history()
end, "git [s]how range history")

-- Toggle inline diff overlay for current hunk
-- See :h MiniDiff.toggle_overlay()
map("n", "<leader>gp", function()
	require("mini.diff").toggle_overlay()
end, "git [p]review hunk inline")

-- Git commands using mini.git's :Git interface
-- See :h mini.git-commands
map("n", "<leader>gb", ":Git blame<CR>", "git [b]lame")
map("n", "<leader>gd", ":Git diff<CR>", "git [d]iff")
map("n", "<leader>gD", ":Git diff HEAD~1<CR>", "git [D]iff against last commit")

-- Buffer-wide git operations
-- See :h :Git for available git commands
map("n", "<leader>gS", ":Git add %<CR>", "git [S]tage buffer")
map("n", "<leader>gR", ":Git restore %<CR>", "git [R]eset buffer")

-- Reset hunk under cursor (alternative to gH mapping)
-- See :h MiniDiff.reset()
map("n", "<leader>gr", function()
	require("mini.diff").reset()
end, "git [r]eset hunk")

-- Toggle git diff signs visibility
-- See :h MiniDiff.toggle()
map("n", "<leader>gtd", function()
	require("mini.diff").toggle()
end, "[T]oggle git [d]iff signs")

-- Toggle git blame view
-- Opens :Git blame in a split window
map("n", "<leader>gtl", function()
	vim.cmd("Git blame")
end, "[T]oggle git show b[l]ame")

-- ADDITIONAL USEFUL COMMANDS:
-- :Git status - Show git status
-- :Git log - Show git log
-- :Git show - Show commit details
-- See :h mini.git-commands for full list
--
-- MINI.DIFF FEATURES:
-- :h MiniDiff.enable() - Enable diff for buffer
-- :h MiniDiff.disable() - Disable diff for buffer
-- :h MiniDiff.toggle_overlay() - Show/hide inline diff
-- :h MiniDiff.export() - Export hunks to quickfix
--
-- TEXT OBJECTS:
-- dgh - Delete hunk under cursor
-- ygh - Yank hunk under cursor
-- vgh - Visual select hunk
--
-- MINI.GIT FEATURES:
-- :h MiniGit.show_at_cursor() - Show git info at cursor
-- :h MiniGit.show_diff_source() - Show source of diff
-- :h MiniGit.show_range_history() - Interactive file history
