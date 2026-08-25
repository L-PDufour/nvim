-- Per-project multiplexer on top of Neovim 0.12's server/UI features.
--
-- Each project root gets its own deterministic listen socket + its own
-- mini.sessions session file, so `cd <project> && nvim` behaves like
-- `tmux -S <project>`:
--
--   • socket live → the TUI `:connect!`s to the running server (rejoin),
--     so windows/tabs/terminals/overseer tasks are exactly as you left them.
--   • socket stale/dead → this instance becomes the project server
--     (`serverstart`), then the project session is restored (or seeded).
--   • `<Leader>sd` / `:detach` walks away; the server keeps running.
--   • `nvim file.go` still opens a plain single edit (auto-join is skipped
--     when file arguments or `--listen` are present).
--
-- Sessions live under stdpath("data")/sessions (mini.sessions) and sockets
-- under stdpath("data")/mux; a crashed instance leaves a stale socket that
-- the liveness check removes before `serverstart`.

local MiniSessions = require("mini.sessions")

-- Reuse the same "project" notion as mini.misc auto_root / compile.lua.
local ROOT_MARKERS = { ".git", "go.mod", "go.work", "flake.nix", "Cargo.toml", "package.json", "Makefile" }

local MUX_DIR = vim.fn.stdpath("data") .. "/mux"
local SESSION_DIR = MiniSessions.config.directory

local function project_root()
	local fname = vim.api.nvim_buf_get_name(0)
	local path = (fname ~= "" and fname) or vim.fn.getcwd()
	return vim.fs.root(path, ROOT_MARKERS)
end

-- Deterministic, filesystem-safe session name per project root.
local function session_name(root)
	local hash = vim.fn.sha256(root):sub(1, 6)
	return string.format("%s-%s", vim.fs.basename(root), hash)
end

local function session_file(name)
	return vim.fs.joinpath(SESSION_DIR, name)
end

local function sock_path(name)
	return vim.fs.joinpath(MUX_DIR, name .. ".sock")
end

-- A live server responds to a connect attempt; a leftover socket file from a
-- crashed instance fails and is cleaned up so `serverstart` can take it over.
-- (sockconnect raises E5108 on connection refused rather than returning 0.)
local function server_live(sock)
	local ok, chan = pcall(vim.fn.sockconnect, "pipe", sock, { rpc = true })
	if ok and chan > 0 then
		vim.fn.chanclose(chan)
		return true
	end
	vim.fn.delete(sock)
	return false
end

local function has_flag(flag)
	for _, arg in ipairs(vim.v.argv) do
		if arg == flag then
			return true
		end
	end
	return false
end

local function save_session(name)
	MiniSessions.write(name, { force = true })
	vim.v.this_session = session_file(name)
end

-- This instance's project-mux socket, once we've `serverstart`ed it. Used to
-- avoid re-connecting to ourselves (vim.v.servername stays the startup
-- socket, not the mux one, so it can't be used for the guard).
local mux_server_sock = nil

local function Mux()
	local root = project_root()
	if not root then
		vim.notify("Mux: no project root found (git/go/flake/…)", vim.log.levels.WARN)
		return
	end

	local name = session_name(root)
	local sock = sock_path(name)

	if mux_server_sock == sock then
		vim.notify(string.format("Mux: already attached to %s", name), vim.log.levels.INFO)
		return
	end

	if server_live(sock) then
		vim.notify(string.format("Mux: attaching to %s (%s)", name, sock), vim.log.levels.INFO)
		local ok, err = pcall(vim.cmd, "connect! " .. vim.fn.fnameescape(sock))
		if not ok then
			vim.notify(string.format("Mux: connect failed: %s", err), vim.log.levels.ERROR)
		end
		return
	end

	-- Fresh (or restarted) project server: take over the socket.
	vim.fn.mkdir(MUX_DIR, "p")
	local ok, addr = pcall(vim.fn.serverstart, sock)
	if not ok or addr == -1 or addr == "" then
		vim.notify(string.format("Mux: failed to listen on %s", sock), vim.log.levels.ERROR)
		return
	end
	mux_server_sock = sock

	-- Only restore when nvim was started with no files (auto-join / restart);
	-- a manual `:Mux` with files open keeps its buffers.
	if vim.fn.argc() == 0 then
		if vim.fn.filereadable(session_file(name)) == 1 then
			MiniSessions.read(name, { force = true })
		else
			save_session(name) -- seed so autowrite has a target
		end
	end
	vim.notify(string.format("Mux: started %s (%s)", name, sock), vim.log.levels.INFO)
end

-- Auto-join: bare `nvim` (no file args, no --listen) inside a project resumes
-- that project's multiplexer session, tmux-style.
if vim.g.mux_auto ~= false then
	Config.autocmd("VimEnter", nil, function()
		if vim.fn.argc() == 0 and not has_flag("--listen") and not has_flag("--server") then
			vim.schedule(function()
				pcall(Mux)
			end)
		end
	end, "Auto-join project multiplexer session")
end

vim.api.nvim_create_user_command("Mux", Mux, { desc = "Join or create the current project's multiplexer session" })

local function nmap_leader(suffix, rhs, desc)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

nmap_leader("sm", function()
	Mux()
end, "Mux: join/resume project session")
nmap_leader("sd", function()
	vim.cmd("detach")
end, "Mux: detach (keep server running)")
nmap_leader("ss", function()
	local root = project_root()
	if root then
		save_session(session_name(root))
	end
end, "Mux: save project session")
nmap_leader("sl", function()
	MiniSessions.select("read")
end, "Mux: pick a session")
nmap_leader("sR", function()
	MiniSessions.restart()
end, "Mux: restart preserving session")

return Mux
