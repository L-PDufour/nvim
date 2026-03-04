local overseer = require("overseer")
require("oil").setup()
overseer.setup()

local function make(target)
	overseer
		.new_task({
			cmd = { "make", target },
			components = { { "on_output_quickfix", open = true }, "default" },
		})
		:start()
end

vim.keymap.set("n", "<leader>mb", function()
	make("build")
end, { desc = "make build" })
vim.keymap.set("n", "<leader>mt", function()
	make("test")
end, { desc = "make test" })
vim.keymap.set("n", "<leader>md", function()
	make("dev")
end, { desc = "make dev" })
vim.keymap.set("n", "<leader>ml", function()
	make("lint")
end, { desc = "make lint" })
vim.keymap.set("n", "<leader>ms", function()
	make("start")
end, { desc = "make start" })
vim.keymap.set("n", "<leader>mo", "<cmd>OverseerToggle<cr>", { desc = "overseer toggle" })
require("quicker").setup()
vim.keymap.set("n", "<leader>qq", function()
	require("quicker").toggle()
end, {
	desc = "Toggle quickfix",
})
vim.keymap.set("n", "<leader>ql", function()
	require("quicker").toggle({ loclist = true })
end, {
	desc = "Toggle loclist",
})
require("quicker").setup({
	keys = {
		{
			">",
			function()
				require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
			end,
			desc = "Expand quickfix context",
		},
		{
			"<",
			function()
				require("quicker").collapse()
			end,
			desc = "Collapse quickfix context",
		},
	},
})
