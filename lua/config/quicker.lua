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

-- Emacs `M-x compile` / `M-x recompile`: prompt for an arbitrary shell
-- command (no target autodetection/enumeration) and remember it for rerun.
local last_compile_cmd = nil

local function compile(cmd)
	last_compile_cmd = cmd
	overseer
		.new_task({
			cmd = cmd,
			name = cmd,
			components = { { "on_output_quickfix", open = true }, "default" },
		})
		:start()
end

vim.keymap.set("n", "<leader>mm", function()
	vim.ui.input({ prompt = "Compile: ", default = last_compile_cmd or "make " }, function(cmd)
		if cmd and cmd ~= "" then
			compile(cmd)
		end
	end)
end, { desc = "compile (prompt for command)" })

vim.keymap.set("n", "<leader>mr", function()
	if not last_compile_cmd then
		vim.notify("No previous compile command", vim.log.levels.WARN)
		return
	end
	compile(last_compile_cmd)
end, { desc = "recompile (rerun last command)" })
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
