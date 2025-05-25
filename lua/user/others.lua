-- Check if snacks is available (in case it's not installed yet)
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

local flash = require("flash")

flash.setup({
	modes = {
		char = { enabled = true }, -- Don't override f/F/t/T
	},
})
vim.keymap.set({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash jump" })
vim.keymap.set({ "n", "x", "o" }, "S", flash.treesitter, { desc = "Flash jump" })
vim.keymap.set("o", "r", flash.remote, { desc = "Flash remote" })
vim.keymap.set({ "o", "x" }, "R", flash.treesitter_search, { desc = "Flash remote" })
