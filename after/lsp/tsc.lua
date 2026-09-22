---@brief
---
--- https://github.com/microsoft/typescript
---
--- TypeScript 7.0+ native compiler, started as `tsc --lsp --stdio`.
--- The `tsc` binary is provided on `$PATH` by the flake (typescript-go).
---
--- ### Monorepo support
---
--- `tsc` supports monorepos by default and finds the `tsconfig.json` or
--- `jsconfig.json` for the package being edited without spawning one
--- server per package.

---@type vim.lsp.Config
return {
	settings = {
		["js/ts"] = {
			inlayHints = {
				parameterNames = { enabled = "literals", suppressWhenArgumentMatchesName = true },
				parameterTypes = { enabled = true },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				enumMemberValues = { enabled = true },
			},
			referencesCodeLens = { enabled = true, showOnAllFunctions = true },
			implementationsCodeLens = {
				enabled = true,
				showOnInterfaceMethods = true,
				showOnAllClassMethods = true,
			},
		},
	},
	cmd = { "tsc", "--lsp", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	root_dir = function(bufnr, on_dir)
		local root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
		root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers, { ".git" } }
			or vim.list_extend(root_markers, { ".git" })
		on_dir(vim.fs.root(bufnr, root_markers) or vim.fn.getcwd())
	end,
}
