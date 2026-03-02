-- Leader mappings ============================================================

-- Neovim has the concept of a Leader key (see `:h <Leader>`). It is a configurable
-- key that is primarily used for "workflow" mappings (opposed to text editing).
-- Like "open file explorer", "create scratch buffer", "pick from buffers".
--
-- In 'plugin/10_options.lua' <Leader> is set to <Space>, i.e. press <Space>
-- whenever there is a suggestion to press <Leader>.
--
-- This config uses a "two key Leader mappings" approach: first key describes
-- semantic group, second key executes an action. Both keys are usually chosen
-- to create some kind of mnemonic.
-- Example: `<Leader>f` groups "find" type of actions; `<Leader>ff` - find files.
-- Use this section to add Leader mappings in a structural manner.
--
-- Usually if there are global and local kinds of actions, lowercase second key
-- denotes global and uppercase - local.
-- Example: `<Leader>fs` / `<Leader>fS` - find workspace/document LSP symbols.
--
-- Many of the mappings use 'mini.nvim' modules set up in 'plugin/30_mini.lua'.

-- Create a global table with information about Leader groups in certain modes.
-- This is used to provide 'mini.clue' with extra clues.
-- Add an entry if you create a new group.

local function map(mode, lhs, rhs, opts)
	opts = opts or {}
	opts.silent = opts.silent ~= false
	vim.keymap.set(mode, lhs, rhs, opts)
end

local nmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end
local xmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("x", "<Leader>" .. suffix, rhs, { desc = desc })
end

-- b is for 'Buffer'. Common usage:
-- - `<Leader>bs` - create scratch (temporary) buffer
-- - `<Leader>ba` - navigate to the alternative buffer
-- - `<Leader>bw` - wipeout (fully delete) current buffer
local new_scratch_buffer = function()
	vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end

nmap_leader("ba", "<Cmd>b#<CR>", "Alternate")
nmap_leader("bd", "<Cmd>lua MiniBufremove.delete()<CR>", "Delete")
nmap_leader("bD", "<Cmd>lua MiniBufremove.delete(0, true)<CR>", "Delete!")
nmap_leader("bs", new_scratch_buffer, "Scratch")
nmap_leader("bw", "<Cmd>lua MiniBufremove.wipeout()<CR>", "Wipeout")
nmap_leader("bW", "<Cmd>lua MiniBufremove.wipeout(0, true)<CR>", "Wipeout!")

-- e is for 'Explore' and 'Edit'. Common usage:
-- - `<Leader>ed` - open explorer at current working directory
-- - `<Leader>ef` - open directory of current file (needs to be present on disk)
-- - `<Leader>ei` - edit 'init.lua'
-- - All mappings that use `edit_plugin_file` - edit 'plugin/' config files
local edit_plugin_file = function(filename)
	return string.format("<Cmd>edit %s/plugin/%s<CR>", vim.fn.stdpath("config"), filename)
end
local explore_at_file = "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>"
local explore_quickfix = function()
	for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.fn.getwininfo(win_id)[1].quickfix == 1 then
			return vim.cmd("cclose")
		end
	end
	vim.cmd("copen")
end

nmap_leader("ed", "<Cmd>lua MiniFiles.open()<CR>", "Directory")
nmap_leader("ef", explore_at_file, "File directory")
nmap_leader("ei", "<Cmd>edit $MYVIMRC<CR>", "init.lua")
nmap_leader("en", "<Cmd>lua MiniNotify.show_history()<CR>", "Notifications")
nmap_leader("eq", explore_quickfix, "Quickfix")

local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. " --follow -- %"

nmap_leader("gc", "<Cmd>Git commit<CR>", "Commit")
nmap_leader("ga", "<Cmd>Git commit --amend<CR>", "Commit amend")
nmap_leader("gd", "<Cmd>Git diff<CR>", "Diff")
nmap_leader("gt", "<Cmd>Git diff -- %<CR>", "Diff this buffer")
nmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at cursor")
nmap_leader("go", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", "Toggle overlay")

-- Git hunks (using mini.pick)
nmap_leader("gh", "<Cmd>Pick git_hunks<CR>", "Hunks modified (all)")
nmap_leader("gk", '<Cmd>Pick git_hunks path="%"<CR>', "Hunks modified (buffer)")
nmap_leader("gl", '<Cmd>Pick git_hunks scope="staged"<CR>', "Hunks staged (all)")
nmap_leader("g;", '<Cmd>Pick git_hunks path="%" scope="staged"<CR>', "Hunks staged (buffer)")

-- Git commits (using mini.pick)
nmap_leader("gf", "<Cmd>Pick git_commits<CR>", "Commits (all)")
nmap_leader("gj", '<Cmd>Pick git_commits path="%"<CR>', "Commits (buffer)")

-- Git log (using mini.git)
nmap_leader("gn", "<Cmd>" .. git_log_cmd .. "<CR>", "Log (all)")
nmap_leader("gm", "<Cmd>" .. git_log_buf_cmd .. "<CR>", "Log (buffer)")

-- Git staged diff
nmap_leader("gp", "<Cmd>Git diff --cached<CR>", "Staged diff (all)")
nmap_leader("gu", "<Cmd>Git diff --cached -- %<CR>", "Staged diff (buffer)")

xmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at selection")

-- local formatting_cmd = '<Cmd>lua require("conform").format({lsp_fallback=true})<CR>'

-- o is for 'Other'. Common usage:
-- - `<Leader>oz` - toggle between "zoomed" and regular view of current buffer
nmap_leader("or", "<Cmd>lua MiniMisc.resize_window()<CR>", "Resize to default width")
nmap_leader("ot", "<Cmd>lua MiniTrailspace.trim()<CR>", "Trim trailspace")
nmap_leader("oz", "<Cmd>lua MiniMisc.zoom()<CR>", "Zoom toggle")

nmap_leader("ut", "<Cmd>UndotreeToggle<CR><Cmd>UndotreeFocus<CR>", "Undo tree")
-- v is for 'Visits'. Common usage:
-- - `<Leader>vv` - add    "core" label to current file.
-- - `<Leader>vV` - remove "core" label to current file.
-- - `<Leader>vc` - pick among all files with "core" label.
local MiniVisits = require("mini.visits")
local MiniExtra = require("mini.extra")
local make_pick_core = function(cwd, desc)
	return function()
		local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
		local local_opts = { cwd = cwd, filter = "core", sort = sort_latest }
		MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
	end
end

nmap_leader("vc", make_pick_core("", "Core visits (all)"), "Core visits (all)")
nmap_leader("vC", make_pick_core(nil, "Core visits (cwd)"), "Core visits (cwd)")
nmap_leader("vv", '<Cmd>lua MiniVisits.add_label("core")<CR>', 'Add "core" label')
nmap_leader("vV", '<Cmd>lua MiniVisits.remove_label("core")<CR>', 'Remove "core" label')
nmap_leader("vl", "<Cmd>lua MiniVisits.add_label()<CR>", "Add label")
nmap_leader("vL", "<Cmd>lua MiniVisits.remove_label()<CR>", "Remove label")

-- d is for 'Debug' (DAP). Common usage:
-- - `<Leader>db` - toggle breakpoint
-- - `<Leader>dc` - continue/start debugging
-- - `<Leader>dt` - terminate debugging session
-- - Function keys: F5 (continue), F10 (step over), F11 (step into), F12 (step out)
local dap = require("dap")
local dapui = require("dapui")

map("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
map("n", "<S-F5>", dap.terminate, { desc = "Debug: Terminate" })
map("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Breakpoint" })
map("n", "<S-F9>", function()
	dap.set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "Debug: Conditional breakpoint" })
map("n", "<F10>", dap.step_over, { desc = "Debug: Step over" })
map("n", "<F11>", dap.step_into, { desc = "Debug: Step into" })
map("n", "<F12>", dap.step_out, { desc = "Debug: Step out" })

-- keep these on leader since they're less frequent
nmap_leader("du", dapui.toggle, "DAP UI toggle")
nmap_leader("de", function()
	dapui.eval(nil, { enter = true })
end, "DAP eval")
nmap_leader("dt", require("dap-go").debug_test, "Debug test")
nmap_leader("dT", require("dap-go").debug_last_test, "Debug last test")

-- stylua: ignore end
-- Override the mappings after setup
vim.keymap.set("n", ";", ":", { noremap = true, desc = "Enter command mode" })
vim.keymap.set("n", ":", ";", { noremap = true, desc = "Repeat f/t motion" })
vim.keymap.set("v", ";", ":", { noremap = true, desc = "Enter command mode" })
vim.keymap.set("v", ":", ";", { noremap = true, desc = "Repeat f/t motion" })

-- Navigation
map("n", "H", "^", { desc = "Jump to line start" })
map("n", "L", "$", { desc = "Jump to line end" })
map("n", "J", "mzJ`z", { desc = "Join lines, keep cursor" })

-- Scrolling (centered)
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
map("n", "n", "nzzzv", { desc = "Next result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous result (centered)" })

-- Window resize
map("n", "<C-Up>", "<Cmd>resize -2<CR>", { desc = "Decrease height" })
map("n", "<C-Down>", "<Cmd>resize +2<CR>", { desc = "Increase height" })
map("n", "<C-Left>", "<Cmd>vertical resize +2<CR>", { desc = "Increase width" })
map("n", "<C-Right>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease width" })

-- Move lines
map("n", "<M-j>", "<Cmd>move .+1<CR>==", { desc = "Move line down" })
map("n", "<M-k>", "<Cmd>move .-2<CR>==", { desc = "Move line up" })
map("v", "J", ":move '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":move '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Visual indenting
map("v", ">", ">gv", { desc = "Indent right" })
map("v", "<", "<gv", { desc = "Indent left" })

-- Common operations
map({ "n", "v" }, "<C-s>", "<Cmd>w<CR>", { desc = "Save file" })
map({ "n", "v" }, "<C-x>", "<Cmd>close<CR>", { desc = "Close window" })
-- map({ "n", "v" }, "<C-c>", "<Cmd>b#<CR>", { desc = "Alternate buffer" })

-- Command mode emacs bindings
map("c", "<C-a>", "<Home>")
map("c", "<C-e>", "<End>")
map("c", "<C-b>", "<Left>")
map("c", "<C-f>", "<Right>")
map("c", "<C-d>", "<Del>")
map("c", "<C-h>", "<BS>")

local terminals = {
	horizontal = { buf = nil, win = nil },
	vertical = { buf = nil, win = nil },
}

local function toggle_terminal(orientation, split_cmd)
	local term = terminals[orientation]

	if term.win and vim.api.nvim_win_is_valid(term.win) then
		vim.api.nvim_win_close(term.win, true)
		term.win = nil
		return
	end

	if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
		vim.cmd(split_cmd)
		term.win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(term.win, term.buf)
		vim.cmd("startinsert")
		return
	end

	vim.cmd(split_cmd)
	vim.cmd("term")
	term.buf = vim.api.nvim_get_current_buf()
	term.win = vim.api.nvim_get_current_win()
	vim.cmd("startinsert")
end

nmap_leader("tt", function()
	toggle_terminal("vertical", "vertical split")
end, "Terminal toggle (vertical)")
nmap_leader("tT", function()
	toggle_terminal("horizontal", "split")
end, "Terminal toggle (horizontal)")
-- Terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Clear search
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
-- Smart quickfix navigation - only use quickfix commands when qf window is open
local function smart_qf_nav(direction)
	return function()
		-- Check if quickfix window is open
		for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.fn.getwininfo(win_id)[1].quickfix == 1 then
				-- Quickfix is open, navigate it
				if direction == "next" then
					vim.cmd("cnext")
				else
					vim.cmd("cprevious")
				end
				vim.cmd("normal! zz") -- Center screen
				return
			end
		end

		-- Quickfix is closed, use default behavior
		if direction == "next" then
			vim.cmd("normal! j")
		else
			vim.cmd("normal! k")
		end
	end
end

map("n", "<C-n>", smart_qf_nav("next"), { desc = "Next (qf or line)" })
map("n", "<C-p>", smart_qf_nav("prev"), { desc = "Previous (qf or line)" })
-- Insert mode navigation (Emacs-style)
map("i", "<C-h>", "<Left>", { desc = "Move left" })
map("i", "<C-l>", "<Right>", { desc = "Move right" })
map("i", "<C-j>", "<Down>", { desc = "Move down" })
map("i", "<C-k>", "<Up>", { desc = "Move up" })
map("i", "<C-a>", "<Home>", { desc = "Move to line start" })
map("i", "<C-e>", "<End>", { desc = "Move to line end" })
map("i", "<C-b>", "<Left>", { desc = "Move backward" })
map("i", "<C-f>", "<Right>", { desc = "Move forward" })
