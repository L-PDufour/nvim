-- ┌────────────────────┐
-- │ MINI configuration │
-- └────────────────────┘

-- Color scheme
vim.cmd("colorscheme catppuccin-frappe")
-- ============================================================================
-- Core Modules (minimal setup)
-- ============================================================================

-- Icon provider
local MiniIcons = require("mini.icons")
local ext3_blocklist = { scm = true, txt = true, yml = true }
local ext4_blocklist = { json = true, yaml = true }

MiniIcons.setup({
	use_file_extension = function(ext, _)
		return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
	end,
})
MiniIcons.mock_nvim_web_devicons()
MiniIcons.tweak_lsp_kind()

-- Miscellaneous utilities
local MiniMisc = require("mini.misc")
MiniMisc.setup()
MiniMisc.setup_auto_root()
MiniMisc.setup_restore_cursor()
MiniMisc.setup_termbg_sync()

-- Notifications
require("mini.notify").setup()

-- Session management
require("mini.sessions").setup()

-- Start screen
require("mini.starter").setup()

-- Statusline
require("mini.statusline").setup()

-- ============================================================================
-- Text Objects & Motions
-- ============================================================================

-- Extra functionality
require("mini.extra").setup()

-- AI textobjects
local ai = require("mini.ai")
ai.setup({
	custom_textobjects = {
		B = MiniExtra.gen_ai_spec.buffer(),
		F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
	},
	search_method = "cover",
})

-- Bracketed navigation
require("mini.bracketed").setup()

-- Indent scope
require("mini.indentscope").setup()

-- Surround
require("mini.surround").setup()

-- Swap arguments with ( and )
vim.keymap.set("n", "(", "gxiagxila", { remap = true, desc = "Swap arg left" })
vim.keymap.set("n", ")", "gxiagxina", { remap = true, desc = "Swap arg right" })

-- ============================================================================
-- Editing
-- ============================================================================

-- Align
require("mini.align").setup()

-- Comment
require("mini.comment").setup()

-- Operators
require("mini.operators").setup()

-- Pairs
require("mini.pairs").setup({ modes = { command = true } })

-- Split/join
require("mini.splitjoin").setup()

-- Trailspace
require("mini.trailspace").setup()

-- ============================================================================
-- File Management
-- ============================================================================

-- Buffer removal
require("mini.bufremove").setup()

-- File explorer
require("mini.files").setup({ windows = { preview = true } })

local add_marks = function()
	MiniFiles.set_bookmark("c", vim.fn.stdpath("config"), { desc = "Config" })
	local minideps_plugins = vim.fn.stdpath("data") .. "/site/pack/deps/opt"
	MiniFiles.set_bookmark("p", minideps_plugins, { desc = "Plugins" })
	MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
end
_G.Config.autocmd("User", "MiniFilesExplorerOpen", add_marks, "Add bookmarks")

-- Visits tracking
require("mini.visits").setup()

-- ============================================================================
-- Git
-- ============================================================================

-- Diff
require("mini.diff").setup()

-- Git integration
require("mini.git").setup()

-- ============================================================================
-- Highlighting & UI
-- ============================================================================

-- Hipatterns
local hipatterns = require("mini.hipatterns")
local hi_words = MiniExtra.gen_highlighter.words
hipatterns.setup({
	highlighters = {
		fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
		hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
		todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
		note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
		hex_color = hipatterns.gen_highlighter.hex_color(),
	},
})

-- ============================================================================
-- Picker
-- ============================================================================

require("mini.pick").setup({
	mappings = {
		paste_register = {
			char = "<C-r>",
			func = function()
				local content = vim.fn.getreg("+")
				local current = MiniPick.get_picker_query() or {}
				table.insert(current, content)
				MiniPick.set_picker_query(current)
			end,
		},
		yank = {
			char = "<C-y>",
			func = function()
				local matches = MiniPick.get_picker_matches()
				if matches and matches.current then
					local item = matches.current
					vim.fn.setreg("+", item.text or tostring(item))
					vim.notify("Yanked: " .. (item.text or tostring(item)), vim.log.levels.INFO)
				end
			end,
		},
	},
})
-- ============================================================================
-- Snippets
-- ============================================================================

local latex_patterns = { "latex/**/*.json", "**/latex.json" }
local lang_patterns = {
	tex = latex_patterns,
	plaintex = latex_patterns,
	markdown_inline = { "markdown.json" },
}

local snippets = require("mini.snippets")
local config_path = vim.fn.stdpath("config")
snippets.setup({
	snippets = {
		snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
		snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
	},
})

-- ============================================================================
-- External Plugins
-- ============================================================================

-- Flash (motion plugin)
local flash = require("flash")
flash.setup({
	modes = {
		char = { enabled = true },
	},
})
vim.keymap.set({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash jump" })
vim.keymap.set({ "n", "x", "o" }, "S", flash.treesitter, { desc = "Flash treesitter" })
vim.keymap.set("o", "r", flash.remote, { desc = "Flash remote" })
vim.keymap.set({ "o", "x" }, "R", flash.treesitter_search, { desc = "Flash treesitter search" })

-- Which-key (keybinding hints)
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
	spec = {},
})
local wk = require("which-key")
wk.add({
	{ "<Leader>b", group = "+Buffer" },
	{ "<Leader>e", group = "+Explore/Edit" },
	{ "<Leader>f", group = "+Find" },
	{ "<Leader>g", group = "+Git" },
	{ "<Leader>l", group = "+Language" },
	{ "<Leader>o", group = "+Other" },
	{ "<Leader>s", group = "+Session" },
	{ "<Leader>t", group = "+Terminal" },
	{ "<Leader>v", group = "+Visits" },
	{
		mode = { "n", "x" },
		{ "<Leader>g", group = "+Git" },
		{ "<Leader>l", group = "+Language" },
	},
})
