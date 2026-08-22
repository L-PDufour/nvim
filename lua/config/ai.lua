-- CodeCompanion: AI chat in a native markdown buffer. One UI, two adapters:
--  • deepseek (http) — direct API calls; default for Q&A and the teaching
--    prompts below. Key is read from ~/.config/deepseek/api_key.
--  • opencode (acp)  — drives the `opencode` CLI as an ACP agent for
--    repo-level questions and multi-file work; model/auth come from
--    opencode's own config (`opencode auth login`, managed in nixcfg).
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
			opts = { modes = { "v" }, short_name = "tutor", auto_submit = true, stop_context_insertion = true },
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
						local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
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
		["Explain"] = {
			strategy = "chat",
			description = "Explain the selected code in depth",
			opts = { modes = { "v" }, short_name = "explain", auto_submit = true, stop_context_insertion = true },
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
						local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
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

map({ "n", "v" }, "<Leader>ac", "<Cmd>CodeCompanionChat Toggle<CR>", "AI chat (deepseek)")
map({ "n", "v" }, "<Leader>aa", "<Cmd>CodeCompanionActions<CR>", "AI action palette")
map("n", "<Leader>ao", "<Cmd>CodeCompanionChat opencode<CR>", "AI chat (opencode agent)")
-- ":" on purpose: keeps the visual range so the selection reaches the prompt
map("v", "<Leader>at", ":CodeCompanion /tutor<CR>", "AI tutor selection")
map("v", "<Leader>ae", ":CodeCompanion /explain<CR>", "AI explain selection")

if vim.fn.filereadable(key_file) == 0 then
	vim.notify("CodeCompanion: no DeepSeek key at " .. key_file, vim.log.levels.WARN)
end
