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

-- Persistent `make dev` hot-reload watcher (air + templ generate --watch). The
-- task stays alive in the background so the dev server keeps running — an Emacs
-- *compile* that never quits.
--   • build/runtime errors stream into the quickfix WITHOUT stealing focus
--     (no `open=true`), so you look them up on demand with :cnext/<leader>qq.
--   • we ping via mini.notify when an error line shows up in the output — this
--     is the real feedback loop, because air swallows build errors and keeps the
--     task alive, so "task exited nonzero" never fires. (See GO_ERRFMT & the
--     on_output_lines handler below.)
--   • starting it a second time toggles it off instead of spawning a duplicate.
local DEV_TASK_NAME = "make dev"

-- Set right before we intentionally stop the watcher, so the resulting status
-- transition doesn't trigger a false "make dev failed" notification.
local dev_stopped_manually = false

-- errorformat tuned for `go build`-style + air/templ output, same grammar as
-- Neovim's own `compiler/go.vim` (ignores "# package" headers, keeps the
-- `file:line:col` / `file:line` forms so the quickfix is navigable, and drops
-- everything else so app log noise stays out of the quickfix). This is what
-- `on_output_quickfix` feeds `getqflist()`.
local GO_ERRFMT = table.concat({
	"%-G# %.%#", -- ignore "# package" headers
	"%A%f:%l:%c: %m",
	"%A%f:%l: %m",
	"%C%*\\s%m", -- continuation/snippet lines
	"%-G%.%#", -- ignore everything else (keeps runtime log noise out of the quickfix)
}, ",")

-- These substrings (lowercased) in a line mean "something is wrong"; we debounce
-- a burst of failing lines into a single notification.
local ERROR_PATTERNS = {
	"level=error",
	"error starting",
	"failed to build",
	"build failed",
	"process exit with code:",
	"syntax error",
	"undefined:",
	"cannot use",
	"redeclared",
	"not enough arguments",
	"too many arguments",
	"connection refused",
	".go:", -- go compiler "file.go:line:col" lines
}

local dev_notify_cooldown = 0

local function dev_notify_if_error(task, lines)
	if dev_stopped_manually then
		return
	end
	local now = vim.loop.now()
	if now - dev_notify_cooldown < 5000 then
		return -- still inside a burst; don't spam
	end
	for _, line in ipairs(lines) do
		local low = line:lower()
		for _, pat in ipairs(ERROR_PATTERNS) do
			if low:find(pat, 1, true) then
				dev_notify_cooldown = now
				vim.notify(
					"make dev: error detected — hit :cnext or <leader>qq",
					vim.log.levels.ERROR
				)
				return
			end
		end
	end
end

local function dev()
	local existing = overseer.list_tasks({ recent_first = true })
	for _, task in ipairs(existing) do
		if task.name == DEV_TASK_NAME and not task:is_disposed() then
			if task:is_running() then
				dev_stopped_manually = true
				task:stop()
			else
				dev_stopped_manually = false
				task:restart()
			end
			return
		end
	end

	dev_stopped_manually = false
	local ok, task = pcall(overseer.new_task, {
		cmd = { "make", "dev" },
		name = DEV_TASK_NAME,
		components = {
			-- no `open`: keep focus on your buffer, errors wait in the quickfix
			{ "on_output_quickfix", errorformat = GO_ERRFMT },
			-- status is driven by the exit code. Don't dispose: `<leader>md`
			-- restarts an existing task after a failure (a disposed one can't).
			"on_exit_set_status",
		},
	})
	if not ok then
		vim.notify("make dev: failed to create task", vim.log.levels.ERROR)
		return
	end
	task:subscribe("on_output_lines", dev_notify_if_error)
	task:subscribe("on_complete", function(_, status)
		if status ~= "FAILURE" or dev_stopped_manually then
			return
		end
		vim.notify("make dev stopped — hit :cnext or <leader>qq for errors", vim.log.levels.ERROR)
	end)
	task:start()
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
nmap_leader("md", dev, "make dev (toggle persistent watcher)")
nmap_leader("ml", function()
	make("lint")
end, "make lint")
nmap_leader("ms", function()
	make("start")
end, "make start")
