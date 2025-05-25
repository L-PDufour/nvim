-- lsp/gopls.lua
return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = function(bufnr, cb)
		local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

		-- Look for Go module files
		local go_roots = {
			"go.mod",
			"go.work",
			".git",
		}

		local go_root = vim.fs.find(go_roots, { upward = true, path = fname })[1]
		if go_root then
			cb(vim.fn.fnamemodify(go_root, ":h"))
		else
			-- Fallback to the directory containing the file
			cb(vim.fn.fnamemodify(fname, ":h"))
		end
	end,
	single_file_support = true,
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			deepCompletion = true,
			completeFunctionCalls = true,
			matcher = "Fuzzy",
			experimentalPostfixCompletions = true,

			-- Inlay hints
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},

			-- Formatting
			gofumpt = true,

			-- Semantic tokens
			semanticTokens = true,

			-- Static analysis
			staticcheck = true,

			-- Vulnerability checking
			vulncheck = "Imports", -- Enable vulnerability scanning

			-- Documentation
			hoverKind = "FullDocumentation",
			linkTarget = "pkg.go.dev",
			linksInHover = true,

			-- Navigation
			importShortcut = "Both",
			symbolMatcher = "FastFuzzy",
			symbolStyle = "Dynamic",
			symbolScope = "all",

			-- Performance settings
			completionBudget = "100ms",
			diagnosticsDelay = "500ms", -- Faster than default 1s
			diagnosticsTrigger = "Edit",
			analysisProgressReporting = true,

			-- Directory filters (exclude common build artifacts)
			directoryFilters = {
				"-**/node_modules",
				"-**/vendor",
				"-**/.git",
				"-**/dist",
				"-**/build",
			},
		},
	},
}
