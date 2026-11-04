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
-- UI actions use 'snacks.nvim' (config/snacks.lua, config/pick.lua); the
-- remaining 'mini.nvim' modules live in config/mini.lua.

-- Leader group descriptions for which-key are registered in config/mini.lua.
-- Add an entry there if you create a new group.

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
-- (`<Leader>bs`/`<Leader>bS` — persistent scratch buffers — live in
-- config/snacks.lua)
nmap_leader("ba", "<Cmd>b#<CR>", "Alternate")
nmap_leader("bd", function()
	Snacks.bufdelete()
end, "Delete")
nmap_leader("bD", function()
	Snacks.bufdelete({ force = true })
end, "Delete!")
nmap_leader("bw", function()
	Snacks.bufdelete({ wipe = true })
end, "Wipeout")
nmap_leader("bW", function()
	Snacks.bufdelete({ force = true, wipe = true })
end, "Wipeout!")

-- e is for 'Explore' and 'Edit'. Common usage:
-- - `<Leader>ed` - open explorer at current working directory
-- - `<Leader>ef` - open directory of current file (needs to be present on disk)
-- - `<Leader>ei` - edit 'init.lua'
-- - All mappings that use `edit_plugin_file` - edit 'plugin/' config files
local edit_plugin_file = function(filename)
	return string.format("<Cmd>edit %s/plugin/%s<CR>", vim.fn.stdpath("config"), filename)
end
local function explore_at_file()
	local buf = vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_get_name(buf) == "" then
		Snacks.explorer()
	else
		Snacks.explorer.reveal({ buf = buf })
	end
end
local explore_quickfix = function()
	for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.fn.getwininfo(win_id)[1].quickfix == 1 then
			return vim.cmd("cclose")
		end
	end
	vim.cmd("copen")
end

nmap_leader("ef", explore_at_file, "File directory")
nmap_leader("ei", "<Cmd>edit $MYVIMRC<CR>", "init.lua")
nmap_leader("en", function()
	Snacks.picker.notifications()
end, "Notifications")
nmap_leader("eq", explore_quickfix, "Quickfix")

-- Git (snacks pickers + lazygit; there is no `:Git` command any more).
local function git_diff_buffer(staged)
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		return vim.notify("Not a file buffer", vim.log.levels.WARN)
	end
	-- `staged = false` stops the finder from adding a second (unstaged)
	-- pass; `--cached` is passed explicitly so it lands before `--`.
	local args = { "--", file }
	if staged then
		table.insert(args, 1, "--cached")
	end
	Snacks.picker.git_diff({ staged = false, cmd_args = args })
end

nmap_leader("gg", function()
	Snacks.lazygit()
end, "Lazygit")
nmap_leader("gc", function()
	Snacks.lazygit()
end, "Commit (lazygit)")
nmap_leader("ga", function()
	Snacks.lazygit()
end, "Commit amend (lazygit)")
nmap_leader("gd", function()
	Snacks.picker.git_diff()
end, "Diff (all)")
nmap_leader("gt", function()
	git_diff_buffer(false)
end, "Diff this buffer")
nmap_leader("gs", function()
	Snacks.picker.git_log_line()
end, "Show at cursor")
nmap_leader("gB", function()
	Snacks.gitbrowse()
end, "Open in browser")
nmap_leader("go", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", "Toggle overlay")

-- Git hunks
nmap_leader("gh", function()
	Snacks.picker.git_diff()
end, "Hunks modified (all)")
nmap_leader("gk", function()
	git_diff_buffer(false)
end, "Hunks modified (buffer)")
nmap_leader("gl", function()
	Snacks.picker.git_diff({ staged = true })
end, "Hunks staged (all)")
nmap_leader("g;", function()
	git_diff_buffer(true)
end, "Hunks staged (buffer)")

-- Git commits
nmap_leader("gf", function()
	Snacks.picker.git_log()
end, "Commits (all)")
nmap_leader("gj", function()
	Snacks.picker.git_log_file()
end, "Commits (buffer)")

-- Git log
nmap_leader("gn", function()
	Snacks.picker.git_log()
end, "Log (all)")
nmap_leader("gm", function()
	Snacks.picker.git_log_file()
end, "Log (buffer)")

-- Git staged diff
nmap_leader("gp", function()
	Snacks.picker.git_diff({ staged = true })
end, "Staged diff (all)")
nmap_leader("gu", function()
	git_diff_buffer(true)
end, "Staged diff (buffer)")

xmap_leader("gs", function()
	local start_line, end_line = vim.fn.line("v"), vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		return vim.notify("Not a file buffer", vim.log.levels.WARN)
	end
	Snacks.picker.git_log({
		cmd_args = { "-L", string.format("%d,%d:%s", start_line, end_line, file) },
	})
end, "Show at selection")

-- local formatting_cmd = '<Cmd>lua require("conform").format({lsp_fallback=true})<CR>'

-- o is for 'Other'. Common usage:
-- - `<Leader>oz` - toggle between "zoomed" and regular view of current buffer
nmap_leader("or", "<Cmd>lua MiniMisc.resize_window()<CR>", "Resize to default width")
nmap_leader("ot", "<Cmd>lua MiniTrailspace.trim()<CR>", "Trim trailspace")
nmap_leader("oz", function()
	Snacks.toggle.zoom():toggle()
end, "Zoom toggle")

nmap_leader("ut", "<Cmd>UndotreeToggle<CR><Cmd>UndotreeFocus<CR>", "Undo tree")

-- d is for 'Debug' (DAP). Launch configurations come from each project's
-- .vscode/launch.json; adapters live in config/dap.lua.
local dap = require("dap")

---Breakpoint on the cursor line, if any (used to prefill prompt defaults).
---@return dap.bp|nil
local function breakpoint_at_cursor()
	local bufnr = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local by_buf = require("dap.breakpoints").get(bufnr)
	return vim.iter(by_buf[bufnr] or {}):find(function(bp)
		return bp.line == line
	end)
end

-- `vim.ui.input` is snacks' floating input here, which honours the
-- `completion` option (`getcompletion`). The expression completer only exists
-- in newer nvim-dap-view (not in the 1.2.1 that nixpkgs ships), so check for
-- it lazily and pass no completer rather than erroring.
local function dv_completion()
	local ok, dv = pcall(require, "dap-view")
	if ok and dv.complete then
		return "customlist,v:lua.require'dap-view'.complete"
	end
end

local function set_condition()
	local bp = breakpoint_at_cursor()
	vim.ui.input({
		prompt = "Breakpoint condition: ",
		completion = dv_completion(),
		default = (bp and bp.condition) or "",
	}, function(input)
		if input == nil then
			return
		end
		dap.set_breakpoint(input ~= "" and input or nil)
	end)
end

local function set_log_point()
	local bp = breakpoint_at_cursor()
	vim.ui.input({
		prompt = "Log point message ({expr} is interpolated): ",
		completion = dv_completion(),
		default = (bp and bp.logMessage) or "",
	}, function(input)
		if input == nil then
			return
		end
		dap.set_breakpoint(nil, nil, input ~= "" and input or nil)
	end)
end

map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Breakpoint" })
map("n", "<leader>dB", set_condition, { desc = "Debug: Conditional breakpoint" })
map("n", "<leader>dL", set_log_point, { desc = "Debug: Log point" })
map("n", "<leader>dc", dap.continue, { desc = "Debug: Continue/start" })
map("n", "<leader>dq", dap.terminate, { desc = "Debug: Terminate" })
map("n", "<leader>di", dap.step_into, { desc = "Debug: Step into" })
map("n", "<leader>do", dap.step_over, { desc = "Debug: Step over" })
map("n", "<leader>dO", dap.step_out, { desc = "Debug: Step out" })
map("n", "<leader>dr", "<Cmd>DapViewJump repl<CR>", { desc = "Debug: REPL" })
map("n", "<leader>dv", "<Cmd>DapViewToggle<CR>", { desc = "Debug: Toggle UI" })
map("n", "<leader>de", "<Cmd>DapViewHover<CR>", { desc = "Debug: Hover value" })
-- ":" on purpose to keep the visual range (the command uses it)
map("v", "<leader>de", ":DapViewHover<CR>", { desc = "Debug: Hover selection" })
map("n", "<leader>dw", "<Cmd>DapViewWatch<CR>", { desc = "Debug: Watch value" })
map("v", "<leader>dw", ":DapViewWatch<CR>", { desc = "Debug: Watch selection" })
-- The disassembly section only exists once nvim-dap-disasm is in the store
-- (see config/dap.lua); don't map a jump to an unknown view until then.
if pcall(require, "dap-disasm") then
	map("n", "<leader>dx", "<Cmd>DapViewJump disassembly<CR>", { desc = "Debug: Disassembly" })
end
nmap_leader("dt", require("dap-go").debug_test, "Debug: Test")
nmap_leader("dT", require("dap-go").debug_last_test, "Debug: Last test")

-- Function keys mirror the common IDE bindings.
map("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
map("n", "<S-F5>", dap.terminate, { desc = "Debug: Terminate" })
map("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Breakpoint" })
map("n", "<S-F9>", set_condition, { desc = "Debug: Conditional breakpoint" })
map("n", "<F10>", dap.step_over, { desc = "Debug: Step over" })
map("n", "<F11>", dap.step_into, { desc = "Debug: Step into" })
map("n", "<F12>", dap.step_out, { desc = "Debug: Step out" })

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
map("c", "<C-d>", "<Del>")
map("c", "<C-h>", "<BS>")

-- Terminal (snacks.terminal; separate ids so both orientations coexist)
nmap_leader("tt", function()
	Snacks.terminal.toggle(nil, { count = 1, win = { position = "right" } })
end, "Terminal toggle (vertical)")
nmap_leader("tT", function()
	Snacks.terminal.toggle(nil, { count = 2, win = { position = "bottom" } })
end, "Terminal toggle (horizontal)")
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Clear search
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
-- Smart quickfix navigation - only use quickfix commands when qf window is open
local function smart_qf_nav(direction)
	return function()
		-- Check if quickfix window is open
		for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.fn.getwininfo(win_id)[1].quickfix == 1 then
				-- Quickfix is open, navigate it (guard in case the list is empty)
				local ok = pcall(vim.cmd, direction == "next" and "cnext" or "cprevious")
				if not ok then
					return
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
map("n", "<leader>ld", function()
	local _, winid = vim.diagnostic.open_float({ scope = "line" })
	if winid then
		vim.api.nvim_set_current_win(winid)
	end
end, { desc = "Line diagnostics" })
map("n", "<leader>od", "<Cmd>DBUIToggle<CR>", { desc = "Database UI" })
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>")
map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>")
map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>")
map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>")
