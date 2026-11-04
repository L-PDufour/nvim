-- CodeCompanion: one UI, four ways in.
--  • <Leader>ac  chat, deepseek (http), no tools — cheap Q&A. Key is read
--                from ~/.config/deepseek/api_key.
--  • <Leader>ax  same chat, but with the `agent` tool group preloaded, so it
--                can read/grep/edit files and run commands. Approvals are
--                `ask` by default: g1 always, g2 once, g3 reject, g4 cancel;
--                `gty` in the chat buffer switches the approval mode.
--                (Tools can also be added to any chat by typing `@`.)
--  • <Leader>ai  inline edit on a selection (or the current line) — no chat
--                buffer; shows a diff, g2 accepts, g3 reverts.
--  • <Leader>ao  opencode (acp) — the `opencode` CLI as an ACP agent for
--                repo-level/multi-file work; model and auth come from
--                opencode's own config (`opencode auth login`, in nixcfg).
--                ACP can't render an agent's plan or use a Neovim terminal,
--                which is why it is the "big job" door, not the default.
--
-- CodeCompanion autoloads AGENTS.md/CLAUDE.md rules from the cwd, so the
-- chat and agent modes inherit this repo's guidelines automatically.
local codecompanion = require("codecompanion")
local key_file = vim.fn.expand("~/.config/deepseek/api_key")

local function deepseek_adapter()
	return require("codecompanion.adapters").extend("deepseek", {
		env = { api_key = "cmd:cat " .. key_file },
		schema = {
			-- deepseek-chat = V3, fast/cheap default;
			-- switch to deepseek-reasoner (R1) from the chat buffer when a
			-- "walk me through why" answer is worth the extra tokens
			model = { default = "deepseek-chat" },
		},
	})
end

local default_adapters = {
	chat = { adapter = "deepseek" },
	inline = { adapter = "deepseek" },
}

codecompanion.setup({
	adapters = {
		http = { deepseek = deepseek_adapter },
		-- opencode's preset ACP adapter needs no tweaking: it finds the
		-- binary on PATH and the agent brings its own model config
	},
	-- `interactions` is the current name for this table; older
	-- codecompanion releases call it `strategies`. Setting both keeps the
	-- config working across the nixpkgs version we happen to be on.
	interactions = default_adapters,
	strategies = default_adapters,

	prompt_library = {
		["Tutor"] = {
			strategy = "chat",
			description = "Socratic tutor on the selected code",
			opts = { modes = { "v" }, alias = "tutor", auto_submit = true, stop_context_insertion = true },
			prompts = {
				{
					role = "system",
					content = "You are a programming tutor. Never hand over a full solution. "
						.. "Work socratically: ask one guiding question at a time, name the "
						.. "underlying concept, and point to what documentation or source to "
						.. "read next. Give away more only when the student is clearly stuck, "
						.. "and then only the next small step.",
				},
				{
					role = "user",
					content = function(context)
						local code = require("codecompanion.helpers.code").get_code(context.start_line, context.end_line)
						return "I want to understand this "
							.. context.filetype
							.. " code:\n\n```"
							.. context.filetype
							.. "\n"
							.. code
							.. "\n```\n\nStart tutoring me on it."
					end,
					opts = { contains_code = true },
				},
			},
		},
		["Teach"] = {
			strategy = "chat",
			description = "Explain the selected code in depth (teacher voice)",
			opts = { modes = { "v" }, alias = "teach", auto_submit = true, stop_context_insertion = true },
			prompts = {
				{
					role = "system",
					content = "You are an expert teacher. Explain code precisely: purpose "
						.. "first, then the important lines, then the non-obvious idioms and "
						.. "pitfalls. Assume an experienced programmer who is new to this "
						.. "particular language or codebase.",
				},
				{
					role = "user",
					content = function(context)
						local code = require("codecompanion.helpers.code").get_code(context.start_line, context.end_line)
						return "Explain this "
							.. context.filetype
							.. " code:\n\n```"
							.. context.filetype
							.. "\n"
							.. code
							.. "\n```"
					end,
					opts = { contains_code = true },
				},
			},
		},
	},
})

local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

-- Agent chat: same markdown buffer as <Leader>ac, but the built-in `agent`
-- tool group (read_file, grep_search, insert_edit_into_file, run_command, ...)
-- is preloaded. `CodeCompanion.chat()` does not forward `tools`, so go
-- through the interaction directly.
local function agent_chat()
	local context = require("codecompanion.utils.context").get(vim.api.nvim_get_current_buf())
	require("codecompanion.interactions.chat").new({ tools = { "agent" }, buffer_context = context })
end

map({ "n", "v" }, "<Leader>ac", "<Cmd>CodeCompanionChat Toggle<CR>", "AI chat (deepseek)")
map({ "n", "v" }, "<Leader>aa", "<Cmd>CodeCompanionActions<CR>", "AI action palette")
map("n", "<Leader>ax", agent_chat, "AI agent chat (tools)")
map("n", "<Leader>ao", "<Cmd>CodeCompanionChat opencode<CR>", "AI chat (opencode agent)")
-- ":" on purpose: keeps the visual range so the selection reaches the prompt.
-- With no prompt the command asks for one, then edits the range in place.
map("v", "<Leader>ai", ":CodeCompanion<CR>", "AI inline edit selection")
map("n", "<Leader>ai", "<Cmd>CodeCompanion<CR>", "AI inline edit")
map("v", "<Leader>at", ":CodeCompanion /tutor<CR>", "AI tutor selection")
map("v", "<Leader>ae", ":CodeCompanion /teach<CR>", "AI explain selection in depth")

if vim.fn.filereadable(key_file) == 0 then
	vim.notify("CodeCompanion: no DeepSeek key at " .. key_file, vim.log.levels.WARN)
end
