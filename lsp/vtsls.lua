return {
	cmd = { "vtsls", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	settings = {
		typescript = {
			inlayHints = {
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				enumMemberValues = { enabled = true },
			},
			preferences = {
				includeCompletionsForModuleExports = true,
				includeCompletionsWithSnippetText = true,
			},
			suggest = {
				includeCompletionsForModuleExports = true,
				includeCompletionsWithSnippetText = true,
			},
		},
		javascript = {
			inlayHints = {
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				enumMemberValues = { enabled = true },
			},
			preferences = {
				includeCompletionsForModuleExports = true,
				includeCompletionsWithSnippetText = true,
			},
			suggest = {
				includeCompletionsForModuleExports = true,
				includeCompletionsWithSnippetText = true,
			},
		},
	},
	root_dir = function(bufnr, cb)
		local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

		local ts_root = vim.fs.find("jsconfig.json", { upward = true, path = fname })[1]
		-- Use the git root to deal with monorepos where TypeScript is installed in the root node_modules folder.
		local git_root = vim.fs.find(".git", { upward = true, path = fname })[1]

		if git_root then
			cb(vim.fn.fnamemodify(git_root, ":h"))
		elseif ts_root then
			cb(vim.fn.fnamemodify(ts_root, ":h"))
		end
	end,
	single_file_support = true,
}
