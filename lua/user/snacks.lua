local ok, snacks = pcall(require, "snacks")
if not ok then
	vim.notify("snacks.nvim not found! Add it to your Nix configuration.", vim.log.levels.WARN)
	return
end

-- Create global Snacks accessor
_G.Snacks = snacks
-- Add a custom startup function that doesn't use lazy.nvim
snacks.dashboard = snacks.dashboard or {}
snacks.dashboard.sections = snacks.dashboard.sections or {}

-- Override the startup section with our own implementation
snacks.dashboard.sections.custom_startup = function()
	-- Count plugins manually

	-- Get Neovim startup time if available
	local startup_time = ""
	if vim.g.startup_time then
		local ms = math.floor(vim.g.startup_time * 100 + 0.5) / 100
		startup_time = " in " .. ms .. "ms"
	end

	return {
		align = "center",
		text = {
			{ "⚡ Neovim loaded ", hl = "footer" },
			{ startup_time, hl = "footer" },
		},
	}
end
-- Configure snacks
snacks.setup({
	animate = { enabled = true },
	bigfile = { enabled = true },
	bufdelete = {},
	dashboard = {
		-- Use the default theme
		theme = "doom",
		-- Custom header
		header = {
			"",
			"   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  ",
			"   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  ",
			"   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  ",
			"   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  ",
			"   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  ",
			"   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  ",
			"",
		},
		-- Custom sections
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 1 },
			{ section = "custom_startup" }, -- Use our custom startup section
		},
	},
	explorer = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
	layout = {},
	lazygit = { enabled = true },
	notifier = {
		enabled = true,
		timeout = 3000,
	},
	picker = { enabled = true },
	quickfile = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	toggle = {},
	words = { enabled = true },
	styles = {
		notification = {
			-- wo = { wrap = true } -- Wrap notifications
		},
	},
})

-- Define keymaps
local function set_keymap(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true, noremap = true })
end

-- Top Pickers & Explorer
set_keymap("n", "<leader><space>", function()
	Snacks.picker.smart()
end, "Smart Find Files")
set_keymap("n", "<leader>,", function()
	Snacks.picker.buffers()
end, "Buffers")
set_keymap("n", "<leader>/", function()
	Snacks.picker.grep()
end, "Grep")
set_keymap("n", "<leader>:", function()
	Snacks.picker.command_history()
end, "Command History")
set_keymap("n", "<leader>n", function()
	Snacks.picker.notifications()
end, "Notification History")
set_keymap("n", "<leader>e", function()
	Snacks.explorer()
end, "File Explorer")

-- Find
set_keymap("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, "Buffers")
set_keymap("n", "<leader>ff", function()
	Snacks.picker.files()
end, "Find Files")
set_keymap("n", "<leader>fg", function()
	Snacks.picker.git_files()
end, "Find Git Files")
set_keymap("n", "<leader>fp", function()
	Snacks.picker.projects()
end, "Projects")
set_keymap("n", "<leader>fr", function()
	Snacks.picker.recent()
end, "Recent")
set_keymap("n", "<leader>fo", function()
	Snacks.picker.files({ cwd = vim.fn.expand("~/Sync") })
end, "Find Org Files")
-- Grep
set_keymap("n", "<leader>sb", function()
	Snacks.picker.lines()
end, "Buffer Lines")
set_keymap("n", "<leader>sB", function()
	Snacks.picker.grep_buffers()
end, "Grep Open Buffers")
set_keymap("n", "<leader>sg", function()
	Snacks.picker.grep()
end, "Grep")
set_keymap({ "n", "x" }, "<leader>sw", function()
	Snacks.picker.grep_word()
end, "Visual selection or word")

-- Search
set_keymap("n", '<leader>s"', function()
	Snacks.picker.registers()
end, "Registers")
set_keymap("n", "<leader>s/", function()
	Snacks.picker.search_history()
end, "Search History")
set_keymap("n", "<leader>sa", function()
	Snacks.picker.autocmds()
end, "Autocmds")
set_keymap("n", "<leader>sc", function()
	Snacks.picker.command_history()
end, "Command History")
set_keymap("n", "<leader>ssC", function()
	Snacks.picker.commands()
end, "Commands")
set_keymap("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, "Diagnostics")
set_keymap("n", "<leader>sD", function()
	Snacks.picker.diagnostics_buffer()
end, "Buffer Diagnostics")
set_keymap("n", "<leader>ssh", function()
	Snacks.picker.help()
end, "Help Pages")
set_keymap("n", "<leader>ssH", function()
	Snacks.picker.highlights()
end, "Highlights")
set_keymap("n", "<leader>ssi", function()
	Snacks.picker.icons()
end, "Icons")
set_keymap("n", "<leader>sj", function()
	Snacks.picker.jumps()
end, "Jumps")
set_keymap("n", "<leader>ssk", function()
	Snacks.picker.keymaps()
end, "Keymaps")
set_keymap("n", "<leader>sl", function()
	Snacks.picker.loclist()
end, "Location List")
set_keymap("n", "<leader>sm", function()
	Snacks.picker.marks()
end, "Marks")
set_keymap("n", "<leader>ssM", function()
	Snacks.picker.man()
end, "Man Pages")
set_keymap("n", "<leader>sp", function()
	Snacks.picker()
end, "Search for Pickers")
set_keymap("n", "<leader>sq", function()
	Snacks.picker.qflist()
end, "Quickfix List")
set_keymap("n", "<leader>sR", function()
	Snacks.picker.resume()
end, "Resume")
set_keymap("n", "<leader>su", function()
	Snacks.picker.undo()
end, "Undo History")
set_keymap("n", "<leader>uC", function()
	Snacks.picker.colorschemes()
end, "Colorschemes")

-- LSP
set_keymap("n", "gd", function()
	-- First try direct navigation, fallback to picker if multiple results
	local result, err = vim.lsp.buf.definition({ reuse_win = true })
	if err or (type(result) == "table" and #result > 1) then
		-- If error or multiple results, use the picker
		Snacks.picker.lsp_definitions()
	end
end, "Goto Definition")
set_keymap("n", "gD", function()
	local result, err = vim.lsp.buf.declaration({ reuse_win = true })
	if err or (type(result) == "table" and #result > 1) then
		Snacks.picker.lsp_declarations()
	end
end, "Goto Declaration")
set_keymap("n", "grr", function()
	local result, err = vim.lsp.buf.references({ reuse_win = true })
	if err or (type(result) == "table" and #result > 1) then
		Snacks.picker.lsp_references()
	end
end, "Goto Implementation")
set_keymap("n", "gri", function()
	local result, err = vim.lsp.buf.implementation({ reuse_win = true })
	if err or (type(result) == "table" and #result > 1) then
		Snacks.picker.lsp_implementations()
	end
end, "Goto Implementation")
set_keymap("n", "gy", function()
	local result, err = vim.lsp.buf.type_definition({ reuse_win = true })
	if err or (type(result) == "table" and #result > 1) then
		Snacks.picker.lsp_type_definitions()
	end
end, "Goto T[y]pe Definition")
set_keymap("n", "<leader>ss", function()
	Snacks.picker.lsp_symbols()
end, "LSP Symbols")
set_keymap("n", "<leader>sS", function()
	Snacks.picker.lsp_workspace_symbols()
end, "LSP Workspace Symbols")

-- Other
set_keymap("n", "<leader>z", function()
	Snacks.zen()
end, "Toggle Zen Mode")
set_keymap("n", "<leader>Z", function()
	Snacks.zen.zoom()
end, "Toggle Zoom")
set_keymap("n", "<leader>.", function()
	Snacks.scratch()
end, "Toggle Scratch Buffer")
set_keymap("n", "<leader>S", function()
	Snacks.scratch.select()
end, "Select Scratch Buffer")
set_keymap("n", "<leader>bd", function()
	Snacks.bufdelete()
end, "Delete Buffer")
set_keymap("n", "<leader>cR", function()
	Snacks.rename.rename_file()
end, "Rename File")
set_keymap({ "n", "v" }, "<leader>gB", function()
	Snacks.gitbrowse()
end, "Git Browse")
set_keymap("n", "<leader>gg", function()
	Snacks.lazygit()
end, "Lazygit")
set_keymap("n", "<leader>un", function()
	Snacks.notifier.hide()
end, "Dismiss All Notifications")
set_keymap("n", "<c-/>", function()
	Snacks.terminal()
end, "Toggle Terminal")
set_keymap("t", "<c-/>", function()
	Snacks.terminal()
end, "Toggle Terminal")
set_keymap({ "n", "t" }, "]]", function()
	Snacks.words.jump(vim.v.count1)
end, "Next Reference")
set_keymap({ "n", "t" }, "[[", function()
	Snacks.words.jump(-vim.v.count1)
end, "Prev Reference")
set_keymap("n", "K", vim.lsp.buf.hover, "Hover Documentation")
set_keymap("n", "<leader>N", function()
	Snacks.win({
		file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
		width = 0.6,
		height = 0.6,
		wo = {
			spell = false,
			wrap = false,
			signcolumn = "yes",
			statuscolumn = " ",
			conceallevel = 3,
		},
	})
end, "Neovim News")

-- Setup globals and toggles when Neovim is fully loaded
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- Setup some globals for debugging
		_G.dd = function(...)
			Snacks.debug.inspect(...)
		end
		_G.bt = function()
			Snacks.debug.backtrace()
		end
		vim.print = _G.dd -- Override print to use snacks for `:=` command

		-- Create toggle mappings
		Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
		Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
		Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
		Snacks.toggle.diagnostics():map("<leader>ud")
		Snacks.toggle.line_number():map("<leader>ul")
		Snacks.toggle
			.option("conceallevel", {
				off = 0,
				on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
			})
			:map("<leader>uc")
		Snacks.toggle.treesitter():map("<leader>uT")
		Snacks.toggle
			.option("background", {
				off = "light",
				on = "dark",
				name = "Dark Background",
			})
			:map("<leader>ub")
		Snacks.toggle.inlay_hints():map("<leader>uh")
		Snacks.toggle.indent():map("<leader>ug")
		Snacks.toggle.dim():map("<leader>uD")
	end,
})

-- vim.keymap.del("n", "grr")
-- vim.keymap.del("n", "gri")
