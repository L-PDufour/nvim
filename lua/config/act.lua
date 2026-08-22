-- Embark-style "act on the thing at point" (g. — think embark-act).
--
-- Collects context-sensitive actions for whatever is under the cursor
-- (diagnostic, URL, file path, git hunk, LSP symbol, plain word) and
-- offers them through vim.ui.select (mini.pick).
--
-- The other half of embark (act on minibuffer candidates) is already
-- covered by mini.pick itself: <C-x> marks an entry, <C-a> marks all,
-- <M-CR> sends the marked entries to the quickfix list — which quicker
-- then makes editable (embark-export + wgrep in one move).

local function candidates()
	local acts = {}
	local function add(label, fn)
		table.insert(acts, { label = label, fn = fn })
	end

	local line = vim.api.nvim_get_current_line()
	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local cword = vim.fn.expand("<cword>")
	local cfile = vim.fn.expand("<cfile>")

	-- Diagnostic at point
	local diags = vim.diagnostic.get(0, { lnum = lnum })
	if #diags > 0 then
		add("diagnostic │ show float", function()
			vim.diagnostic.open_float({ scope = "line" })
		end)
		add("diagnostic │ yank message", function()
			vim.fn.setreg("+", diags[1].message)
			vim.notify("Yanked diagnostic message")
		end)
	end

	-- URL on the line
	local url = line:match("https?://[%w%-_%.%?%.:/%+=&%%#@~]+")
	if url then
		add("url │ open " .. url, function()
			vim.ui.open(url)
		end)
		add("url │ yank", function()
			vim.fn.setreg("+", url)
		end)
	end

	-- File path under cursor
	if cfile ~= "" then
		local path = vim.fn.expand(cfile)
		if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
			add("file │ edit " .. cfile, function()
				vim.cmd.edit(path)
			end)
			add("file │ split", function()
				vim.cmd.split(path)
			end)
			add("file │ explore directory", function()
				MiniFiles.open(path)
			end)
			add("file │ yank path", function()
				vim.fn.setreg("+", path)
			end)
		end
	end

	-- Git hunk / history at point (only in git-tracked buffers)
	if require("mini.diff").get_buf_data(0) ~= nil then
		add("git │ show at cursor (hunk/blame)", function()
			MiniGit.show_at_cursor()
		end)
		add("git │ toggle diff overlay", function()
			MiniDiff.toggle_overlay()
		end)
	end

	-- LSP symbol at point
	if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
		add("lsp │ code action", vim.lsp.buf.code_action)
		add("lsp │ rename", vim.lsp.buf.rename)
		add("lsp │ references", function()
			MiniExtra.pickers.lsp({ scope = "references" })
		end)
		add("lsp │ hover doc", vim.lsp.buf.hover)
	end

	-- Plain word fallbacks
	if cword ~= "" then
		add("word │ grep project: " .. cword, function()
			MiniPick.builtin.grep({ pattern = cword })
		end)
		add("word │ help: " .. cword, function()
			local ok = pcall(vim.cmd.help, cword)
			if not ok then
				vim.notify("No help for " .. cword, vim.log.levels.WARN)
			end
		end)
	end

	return acts
end

local function act()
	local acts = candidates()
	if #acts == 0 then
		return vim.notify("Nothing to act on here", vim.log.levels.INFO)
	end
	vim.ui.select(acts, {
		prompt = "Act on thing at point",
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if choice then
			choice.fn()
		end
	end)
end

vim.keymap.set("n", "g.", act, { desc = "Act at point (embark)" })
