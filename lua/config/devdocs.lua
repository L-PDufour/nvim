-- DevDocs: offline documentation browser (maskudo/devdocs.nvim).
-- jq, curl and pandoc are provided on PATH by the Nix wrapper.
require("devdocs").setup({
	ensure_installed = {
		"go",
		"typescript",
		"javascript",
		"c",
		"cpp",
		"python~3.12",
		"lua~5.4",
		"nix",
	},
})

local function map(suffix, rhs, desc)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

map("hg", "<Cmd>DevDocs get<CR>", "Docs: Browse installed")
map("hi", "<Cmd>DevDocs install<CR>", "Docs: Install")
map("hd", "<Cmd>DevDocs delete<CR>", "Docs: Delete")
map("hf", "<Cmd>DevDocs fetch<CR>", "Docs: Fetch metadata")
