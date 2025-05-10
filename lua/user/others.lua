-- Check if snacks is available (in case it's not installed yet)
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
		enabled = true,
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
		-- Define buttons
		buttons = {
			{ "f", "  Find File", ":lua Snacks.picker.files()<CR>" },
			{ "n", "  New File", ":ene<CR>" },
			{ "r", "  Recent Files", ":lua Snacks.picker.recent()<CR>" },
			{ "g", "  Find Word", ":lua Snacks.picker.grep()<CR>" },
			{ "c", "  Configuration", ":lua Snacks.picker.files({cwd = vim.fn.stdpath('config')})<CR>" },
			{ "q", "  Quit", ":qa<CR>" },
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
set_keymap("n", "<leader>fc", function()
	Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, "Find Config File")
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
set_keymap("n", "<leader>sC", function()
	Snacks.picker.commands()
end, "Commands")
set_keymap("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, "Diagnostics")
set_keymap("n", "<leader>sD", function()
	Snacks.picker.diagnostics_buffer()
end, "Buffer Diagnostics")
set_keymap("n", "<leader>sh", function()
	Snacks.picker.help()
end, "Help Pages")
set_keymap("n", "<leader>sH", function()
	Snacks.picker.highlights()
end, "Highlights")
set_keymap("n", "<leader>si", function()
	Snacks.picker.icons()
end, "Icons")
set_keymap("n", "<leader>sj", function()
	Snacks.picker.jumps()
end, "Jumps")
set_keymap("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, "Keymaps")
set_keymap("n", "<leader>sl", function()
	Snacks.picker.loclist()
end, "Location List")
set_keymap("n", "<leader>sm", function()
	Snacks.picker.marks()
end, "Marks")
set_keymap("n", "<leader>sM", function()
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
	Snacks.picker.lsp_definitions()
end, "Goto Definition")
set_keymap("n", "gD", function()
	Snacks.picker.lsp_declarations()
end, "Goto Declaration")
set_keymap("n", "gr", function()
	Snacks.picker.lsp_references()
end, "References")
set_keymap("n", "gI", function()
	Snacks.picker.lsp_implementations()
end, "Goto Implementation")
set_keymap("n", "gy", function()
	Snacks.picker.lsp_type_definitions()
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
set_keymap("n", "<c-_>", function()
	Snacks.terminal()
end, "Toggle Terminal")
set_keymap({ "n", "t" }, "]]", function()
	Snacks.words.jump(vim.v.count1)
end, "Next Reference")
set_keymap({ "n", "t" }, "[[", function()
	Snacks.words.jump(-vim.v.count1)
end, "Prev Reference")

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
local harpoon = require("harpoon")
require("lazydev").setup({ ft = "lua" })
harpoon:setup()
vim.keymap.set("n", "<leader>ha", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<leader>he", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<A-C-j>", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<A-C-k>", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<A-C-l>", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<A-C-;>", function()
	harpoon:list():select(4)
end)
-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<A-C-P>", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<A-C-N>", function()
	harpoon:list():next()
end)
require("trouble").setup({
	auto_close = true,
	-- keys = {
	-- 	-- Additional key mappings for navigation and interaction
	-- 	["<c-n>"] = require("trouble.modes").next,
	-- 	["<c-p>"] = require("trouble.modes").prev,
	-- 	["<cr>"] = "jump_close", -- Jump to item and close Trouble window
	-- },
})
vim.keymap.set("n", "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble toggle" })
vim.keymap.set("n", "<leader>tb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Trouble buffer" })
vim.keymap.set("n", "<leader>ts", "<cmd>Trouble symbols toggle win.position=bottom<cr>", { desc = "Trouble symbols" })
vim.keymap.set("n", "<leader>tl", "<cmd>Trouble lsp toggle<cr>", { desc = "Trouble lsp" })
vim.keymap.set("n", "<leader>tc", "<cmd>Trouble loclist toggle<cr>", { desc = "Trouble loclist" })
vim.keymap.set("n", "<leader>tq", "<cmd>Trouble qflist toggle<cr>", { desc = "Trouble qflist" })
vim.keymap.set("n", "<C-n>", function()
	if require("trouble").is_open() then
		require("trouble").next({ skip_groups = true, jump = true })
	else
		pcall(vim.cmd.cnext)
	end
end, { desc = "Next Trouble/Quickfix Item" })

vim.keymap.set("n", "<C-p>", function()
	if require("trouble").is_open() then
		require("trouble").prev({ skip_groups = true, jump = true })
	else
		pcall(vim.cmd.cprev)
	end
end, { desc = "Previous Trouble/Quickfix Item" })
require("better_escape").setup()
require("which-key").setup({
	plugins = {
		marks = true,
		registers = true,
		spelling = {
			enabled = true,
			suggestions = 20,
		},
	},
	icons = {
		breadcrumb = "»",
		separator = "➜",
		group = "+",
	},
	-- win = {
	-- 	border = "single",
	-- 	padding = { 2, 2, 2, 2 },
	-- },
	spec = {
		-- { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
		-- { "<leader>d", group = "[D]ocument" },
		{ "<leader>g", group = "[G]it" },
		{ "<leader>s", group = "[S]earch" },
		{ "<leader>f", group = "[F]ind" },
		{ "<leader>j", group = "Ft things" },
		{ "<leader>l", group = "[L]sp" },
		{ "<leader>h", group = "[H]elp" },
		{ "<leader>o", group = "[O]rg" },
		{ "<leader>q", group = "[Q]uickfix" },
		{ "<leader>u", group = "[U]ndo" },
		{ "s", group = "Surround", mode = { "n", "v" } },
	},
})

require("flash").setup({
	modes = {
		search = { enabled = true }, -- Don't override / search
		char = { enabled = true }, -- Don't override f/F/t/T
	},
})
vim.keymap.set("n", "<leader>l", require("flash").jump, { desc = "Flash jump" })
vim.keymap.set("o", "r", require("flash").remote, { desc = "Flash remote" })
