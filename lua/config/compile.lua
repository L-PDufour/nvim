-- Emacs-style `M-x compile` on top of overseer + quickfix (quicker).
--
-- :Compile   — prompt for a shell command (last one prefilled, persisted
--              per project like savehist), run it async, errors → quickfix
-- :Recompile — rerun the last compile without prompting (`g` in Emacs)
local overseer = require("overseer")
overseer.setup()

-- Last compile command per project directory, persisted across sessions
local state_file = vim.fn.stdpath("state") .. "/compile_history.json"

local function read_state()
	local ok, lines = pcall(vim.fn.readfile, state_file)
	if not ok then
		return {}
	end
	local ok_decode, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
	return (ok_decode and type(decoded) == "table") and decoded or {}
end

local function write_state(state)
	pcall(vim.fn.writefile, { vim.json.encode(state) }, state_file)
end

local function run_compile(cmd)
	local state = read_state()
	state[vim.fn.getcwd()] = cmd
	write_state(state)
	overseer
		.new_task({
			cmd = cmd, -- string: run through the shell, like Emacs compile
			name = "compile: " .. cmd,
			components = { { "on_output_quickfix", open = true }, "default" },
		})
		:start()
end

local function compile()
	local default = read_state()[vim.fn.getcwd()] or "make -k"
	vim.ui.input(
		{ prompt = "Compile command: ", default = default, completion = "shellcmd" },
		function(input)
			if input and input ~= "" then
				run_compile(input)
			end
		end
	)
end

local function recompile()
	-- Prefer restarting the task itself (keeps its output buffer in the
	-- overseer task list); fall back to the persisted command.
	for _, task in ipairs(overseer.list_tasks({ recent_first = true })) do
		if task.name:find("^compile: ") then
			overseer.run_action(task, "restart")
			return
		end
	end
	local last = read_state()[vim.fn.getcwd()]
	if last then
		run_compile(last)
	else
		compile()
	end
end

vim.api.nvim_create_user_command("Compile", compile, { desc = "Prompt and run a compile command" })
vim.api.nvim_create_user_command("Recompile", recompile, { desc = "Rerun the last compile command" })

-- Restart the most recent task of any kind (recipe from overseer's docs;
-- there is no builtin command for this).
vim.api.nvim_create_user_command("OverseerRestartLast", function()
	local tasks = overseer.list_tasks({ recent_first = true })
	if vim.tbl_isempty(tasks) then
		vim.notify("No tasks found", vim.log.levels.WARN)
	else
		overseer.run_action(tasks[1], "restart")
	end
end, {})

local function make(target)
	overseer
		.new_task({
			cmd = { "make", target },
			components = { { "on_output_quickfix", open = true }, "default" },
		})
		:start()
end

local nmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

nmap_leader("mc", "<Cmd>Compile<CR>", "Compile")
nmap_leader("mr", "<Cmd>Recompile<CR>", "Recompile")
nmap_leader("mm", "<Cmd>OverseerRun<CR>", "Run task (pick template)")
nmap_leader("mR", "<Cmd>OverseerRestartLast<CR>", "Restart last task (any)")
nmap_leader("mo", "<Cmd>OverseerToggle<CR>", "Overseer toggle")

nmap_leader("mb", function()
	make("build")
end, "make build")
nmap_leader("mt", function()
	make("test")
end, "make test")
nmap_leader("md", function()
	make("dev")
end, "make dev")
nmap_leader("ml", function()
	make("lint")
end, "make lint")
nmap_leader("ms", function()
	make("start")
end, "make start")
