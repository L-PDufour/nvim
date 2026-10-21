-- ┌────────────────────┐
-- │ MINI configuration │
-- └────────────────────┘

-- Color scheme
-- vim.cmd("colorscheme catppuccin-frappe")
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

-- Start screen
-- require("mini.starter").setup()

-- Statusline
local MiniStatusline = require("mini.statusline")
MiniStatusline.setup({
	content = {
		active = function()
			local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
			local rec = vim.fn.reg_recording()
			if rec ~= "" then
				mode_hl = "MiniStatuslineModeReplace"
			end
			local git = MiniStatusline.section_git({ trunc_width = 40 })
			local diff = MiniStatusline.section_diff({ trunc_width = 75 })
			local lsp = MiniStatusline.section_lsp({ trunc_width = 40 })
			local filename = MiniStatusline.section_filename({ trunc_width = 140 })
			local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
			local location = MiniStatusline.section_location({ trunc_width = 75 })
			local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

			local groups = {
				{ hl = mode_hl, strings = { mode } },
			}
			if rec ~= "" then
				table.insert(groups, { hl = "MiniStatuslineModeReplace", strings = { "● REC @" .. rec } })
			end
			vim.list_extend(groups, {
				{ hl = "MiniStatuslineDevinfo", strings = { git, diff, vim.diagnostic.status(0), lsp } },
				"%<",
				{ hl = "MiniStatuslineFilename", strings = { filename } },
				"%=",
				{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
				{ hl = mode_hl, strings = { search, location } },
			})

			return MiniStatusline.combine_groups(groups)
		end,
	},
})

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
	MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
end
_G.Config.autocmd("User", "MiniFilesExplorerOpen", add_marks, "Add bookmarks")

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
-- Pickers & Input
-- ============================================================================

-- Pick (replaces fzf-lua); also take over `vim.ui.select`
local MiniPick = require("mini.pick")
MiniPick.setup()
vim.ui.select = MiniPick.ui_select

-- Floating `vim.ui.input` (LSP rename, compile prompt, etc.)
local MiniInput = require("mini.input")
MiniInput.setup()
vim.ui.input = MiniInput.ui_input

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
	{ "<Leader>a", group = "+AI" },
	{ "<Leader>b", group = "+Buffer" },
	{ "<Leader>d", group = "+Debug" },
	{ "<Leader>e", group = "+Explore/Edit" },
	{ "<Leader>f", group = "+Find" },
	{ "<Leader>g", group = "+Git" },
	{ "<Leader>h", group = "+Help/Docs" },
	{ "<Leader>l", group = "+Language" },
	{ "<Leader>m", group = "+Make/Compile" },
	{ "<Leader>o", group = "+Other" },
	{ "<Leader>q", group = "+Quickfix" },
	{ "<Leader>t", group = "+Terminal" },
	{
		mode = { "n", "x" },
		{ "<Leader>g", group = "+Git" },
		{ "<Leader>l", group = "+Language" },
	},
})
