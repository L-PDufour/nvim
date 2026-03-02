require("fzf-lua").setup({
	-- MISC GLOBAL SETUP OPTIONS, SEE BELOW
	-- fzf_bin = ...,
	-- each of these options can also be passed as function that return options table
	-- e.g. winopts = function() return { ... } end
	keymap = {
		-- Below are the default binds, setting any value in these tables will override
		-- the defaults, to inherit from the defaults change [1] from `false` to `true`
		builtin = {
			-- neovim `:tmap` mappings for the fzf win
			-- true,        -- uncomment to inherit all the below in your custom config
			["<M-Esc>"] = "hide", -- hide fzf-lua, `:FzfLua resume` to continue
			["<C-/>"] = "toggle-help",
			["<F2>"] = "toggle-fullscreen",
			-- Only valid with the 'builtin' previewer
			["<F3>"] = "toggle-preview-wrap",
			["<F4>"] = "toggle-preview",
			-- Rotate preview clockwise/counter-clockwise
			["<F5>"] = "toggle-preview-cw",
			-- Preview toggle behavior default/extend
			["<F6>"] = "toggle-preview-behavior",
			-- `ts-ctx` binds require `nvim-treesitter-context`
			["<F7>"] = "toggle-preview-ts-ctx",
			["<F8>"] = "preview-ts-ctx-dec",
			["<F9>"] = "preview-ts-ctx-inc",
			["<S-Left>"] = "preview-reset",
			["<S-down>"] = "preview-page-down",
			["<S-up>"] = "preview-page-up",
			["<M-S-down>"] = "preview-down",
			["<M-S-up>"] = "preview-up",
		},
		fzf = {
			-- fzf '--bind=' options
			-- true,        -- uncomment to inherit all the below in your custom config
			["ctrl-z"] = "abort",
			["ctrl-u"] = "unix-line-discard",
			["ctrl-f"] = "half-page-down",
			["ctrl-b"] = "half-page-up",
			["ctrl-a"] = "beginning-of-line",
			["ctrl-e"] = "end-of-line",
			["alt-a"] = "toggle-all",
			["alt-g"] = "first",
			["alt-G"] = "last",
			-- Only valid with fzf previewers (bat/cat/git/etc)
			["f3"] = "toggle-preview-wrap",
			["f4"] = "toggle-preview",
			["shift-down"] = "preview-page-down",
			["shift-up"] = "preview-page-up",
		},
	},
	fzf_opts = { ["--cycle"] = true },
})
local fzf = require("fzf-lua")

local map = vim.keymap.set
local nmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end
nmap_leader("ff", fzf.files, "Files")
nmap_leader("fh", fzf.helptags, "Help tags")
nmap_leader(".", fzf.resume, "Resume")
nmap_leader("fd", function()
	fzf.diagnostics_document()
end, "Diagnostic buf")
nmap_leader("fD", function()
	fzf.diagnostics_document()
end, "Diagnostic workspace")
nmap_leader("fs", fzf.lsp_live_workspace_symbols, "Symbols workspace")
nmap_leader("fm", fzf.marks, "Marks")
nmap_leader("fr", fzf.registers, "Registers")
nmap_leader("<space>", fzf.live_grep, "Grep live")
nmap_leader("/", fzf.lines, "Lines (all)")
nmap_leader("fw", fzf.grep_cword, "Grep word")
nmap_leader("j/", function()
	fzf.search_history()
end, '"/" history')
nmap_leader("j;", function()
	fzf.command_history()
end, '":" history')
nmap_leader("k", fzf.buffers, "Buffers")

-- files
-- map("n", "<leader>ff", fzf.files, { desc = "Find files" })
-- map("n", "<leader>fo", fzf.oldfiles, { desc = "Recent files" })
-- map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
--
-- -- grep
-- map("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
-- map("n", "<leader>fw", fzf.grep_cword, { desc = "Grep word under cursor" })
-- map("n", "<leader>fW", fzf.grep_cWORD, { desc = "Grep WORD under cursor" })
--
-- -- lsp
-- map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Document diagnostics" })
-- map("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Workspace diagnostics" })
-- map("n", "gd", fzf.lsp_definitions, { desc = "LSP definitions" })
-- map("n", "grr", fzf.lsp_references, { desc = "LSP references" })
-- map("n", "gra", fzf.lsp_code_actions, { desc = "LSP code actions" })
-- map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Document symbols" })
--
-- -- misc
-- map("n", "<leader>fh", fzf.helptags, { desc = "Help tags" })
-- map("n", "<leader>fc", fzf.commands, { desc = "Commands" })
-- map("n", "<leader>fr", fzf.resume, { desc = "Resume last picker" })
-- map("n", "<leader>f/", fzf.search_history, { desc = "Search history" })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local fzf = require("fzf-lua")
		local buf = { buffer = args.buf }

		local function map_buf(mode, lhs, rhs)
			map(mode, lhs, rhs, buf)
		end

		map_buf("n", "grr", function()
			fzf.lsp_references({ ignore_current_line = true, includeDeclaration = false })
		end)
		map_buf("n", "gri", fzf.lsp_implementations)
		map_buf("n", "grt", fzf.lsp_typedefs)
		map_buf("n", "gra", vim.lsp.buf.code_action)
		map_buf("n", "gO", fzf.lsp_document_symbols)
		map_buf("n", "gd", function()
			fzf.lsp_definitions({ jump_to_single_result = true })
		end)
		map_buf("n", "gD", fzf.lsp_declarations)
	end,
})
