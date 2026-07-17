---@brief
---
--- https://templ.guide
---
--- The official language server for the templ HTML templating language.

---@type vim.lsp.Config
return {
	cmd = {"go", "tool", "templ", "lsp" },
	filetypes = { "templ" },
	root_markers = { "go.work", "go.mod", ".git" },
	capabilities = {
		workspace = {
			-- Off by default on Linux; templ's internal gopls relies on
			-- watching **/*.go to pick up struct/type changes.
			didChangeWatchedFiles = {
				dynamicRegistration = true,
			},
		},
	},
}
