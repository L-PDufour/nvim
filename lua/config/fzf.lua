require("fzf-lua").setup({
	"max-perf",
	-- MISC GLOBAL SETUP OPTIONS, SEE BELOW
	-- fzf_bin = ...,
	-- each of these options can also be passed as function that return options table
	-- e.g. winopts = function() return { ... } end
	defaults = {
		git_icons = false,
		file_icons = false,
		color_icons = false,
	},
	previewers = {
		bat = {
			theme = "Everforest",
		},
	},
	lsp = { jump1 = true, includeDeclaration = false },
	blines = { previewer = false },
})
local fzf = require("fzf-lua")
fzf.register_ui_select(function(_, items)
	local min_h, max_h = 0.15, 0.70
	local h = (#items + 4) / vim.o.lines
	if h < min_h then
		h = min_h
	elseif h > max_h then
		h = max_h
	end
	return { winopts = { height = h, width = 0.60, row = 0.40 } }
end)
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
nmap_leader("/", fzf.blines, "Lines")
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
			fzf.lsp_references()
		end)
		map_buf("n", "gri", fzf.lsp_implementations)
		map_buf("n", "grt", fzf.lsp_typedefs)
		map_buf("n", "gra", vim.lsp.buf.code_action)
		map_buf("n", "gO", fzf.lsp_document_symbols)
		map_buf("n", "gd", function()
			fzf.lsp_definitions()
		end)
		map_buf("n", "gD", fzf.lsp_declarations)
	end,
})
