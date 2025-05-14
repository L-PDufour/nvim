-- Set up LSP in lua/user/lsp.lua for Neovim 0.11+
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})
-- Configure diagnostics globally
vim.diagnostic.config({
	-- Virtual text is now disabled by default in Neovim 0.11 and must be explicitly enabled
	virtual_text = {
		prefix = "■ ", -- Could be '●', '▎', 'x', '■'
	},
	-- Configure floating window appearance
	float = { border = "rounded" },
	-- You can show virtual lines instead of virtual text (new feature in 0.11)
	-- virtual_lines = true,
	-- Or only show virtual text on the current line
	-- virtual_text = { current_line = true },
	-- Sort diagnostics by severity
	severity_sort = true,
	-- Configure signs appearance via diagnostic config
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN] = "W",
			[vim.diagnostic.severity.INFO] = "I",
			[vim.diagnostic.severity.HINT] = "H",
		},
	},
})
vim.lsp.config.vtsls = {
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	settings = {
		typescript = {
			inlayHints = {
				includeInlayParameterNameHints = "literal",
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = false,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			},
			-- Enable vtsls's own code quality features
			suggest = {
				enabled = true,
				includeCompletionsForModuleExports = true,
			},
			preferences = {
				includeInlayParameterNameHints = "all",
				includeInlayFunctionParameterTypeHints = true,
			},
		},
		javascript = {
			suggest = {
				enabled = true,
				includeCompletionsForModuleExports = true,
			},
		},
	},
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		-- Keybindings specific to vtsls
		vim.keymap.set(
			"n",
			"<leader>lo",
			":VtsExec organize_imports<CR>",
			{ buffer = bufnr, desc = "Organize Imports" }
		)
		vim.keymap.set(
			"n",
			"<leader>lu",
			":VtsExec remove_unused_imports<CR>",
			{ buffer = bufnr, desc = "Remove Unused Imports" }
		)
	end,
}

vim.lsp.config.eslint = {
	settings = {
		experimental = {
			useFlatConfig = true,
		},
		-- Disable auto-fixing since we use prettier
		codeActionOnSave = {
			enable = false, -- Don't auto-fix on save
			mode = "problems", -- Only fix errors, not warnings
		},
		format = false, -- Let prettier handle formatting
		quiet = false, -- Show ESLint output
		run = "onType", -- Run on type for immediate feedback
		validate = "on",
		workingDirectory = {
			mode = "location",
		},
		-- Don't override rules here - use your .eslintrc file
	},
	on_attach = function(client, bufnr)
		-- Disable ESLint's formatting capability completely
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false

		-- Manual ESLint commands when you need them
		vim.keymap.set("n", "<leader>le", ":EslintFixAll<CR>", { buffer = bufnr, desc = "ESLint Fix All (Manual)" })
	end,
}
-- Then enable it
vim.lsp.enable("vtsls")
-- Enable configured servers
-- vim.lsp.enable("lua_ls")
-- vim.lsp.enable("clangd")
-- vim.lsp.enable("gopls")
-- vim.lsp.enable("html")
-- vim.lsp.enable("htmx")
-- vim.lsp.enable("nil_ls")
-- vim.lsp.enable("tailwindcss")
-- vim.lsp.enable("templ")
vim.lsp.enable("eslint")
-- vim.lsp.config("eslint", {
-- 	--- ...
-- 	on_attach = function(client, bufnr)
-- 		vim.api.nvim_create_autocmd("BufWritePre", {
-- 			buffer = bufnr,
-- 			command = "EslintFixAll",
-- 		})
-- 	end,
-- })
