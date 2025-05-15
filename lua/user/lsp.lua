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

-- vim.lsp.config.eslint_d = {
-- 	cmd = { "eslint_d", "--stdio" },
-- 	filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
-- 	root_dir = function(bufnr, cb)
-- 		-- Convert buffer to filename
-- 		local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))
--
-- 		-- First try to find ESLint config files
-- 		local eslint_config_files = {
-- 			".eslintrc",
-- 			".eslintrc.json",
-- 			".eslintrc.js",
-- 			".eslintrc.cjs",
-- 			".eslintrc.mjs",
-- 			".eslintrc.yml",
-- 			".eslintrc.yaml",
-- 			"eslint.config.js",
-- 			"eslint.config.mjs",
-- 			"eslint.config.cjs",
-- 		}
--
-- 		local root = vim.fs.find(eslint_config_files, {
-- 			path = fname,
-- 			upward = true,
-- 			type = "file",
-- 		})[1]
--
-- 		if root then
-- 			cb(vim.fs.dirname(root))
-- 			return
-- 		end
--
-- 		-- Fallback to package.json or .git
-- 		root = vim.fs.find({ "package.json", ".git" }, {
-- 			path = fname,
-- 			upward = true,
-- 			type = "file",
-- 		})[1]
--
-- 		if root then
-- 			cb(vim.fs.dirname(root))
-- 		else
-- 			cb(vim.fn.getcwd())
-- 		end
-- 	end,
-- 	handlers = {
-- 		-- Custom handler to parse eslint_d output
-- 		["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
-- 			-- You can customize how diagnostics are displayed here
-- 			vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
-- 		end,
-- 	},
-- 	on_attach = function(client, bufnr)
-- 		-- Disable semantic tokens as ESLint doesn't provide them
-- 		client.server_capabilities.semanticTokensProvider = nil
--
-- 		-- Create a command for ESLint fixing
-- 		vim.api.nvim_buf_create_user_command(bufnr, "EslintFixAll", function()
-- 			vim.lsp.buf.code_action({
-- 				filter = function(action)
-- 					return action.title == "Fix all auto-fixable problems"
-- 				end,
-- 				apply = true,
-- 			})
-- 		end, {})
--
-- 		-- Optional: Auto-fix on save
-- 		vim.api.nvim_create_autocmd("BufWritePre", {
-- 			buffer = bufnr,
-- 			callback = function()
-- 				vim.cmd("EslintFixAll")
-- 			end,
-- 		})
-- 	end,
-- }

-- Enable eslint_d
-- vim.lsp.enable("eslint_d")

vim.lsp.config.vtsls = {
	cmd = { "vtsls", "--stdio" },
	filetypes = {
		"vue",
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	root_markers = {
		"tsconfig.json",
		"package.json",
		"jsconfig.json",
		".git",
	},
	settings = {
		complete_function_calls = true,
		vtsls = {
			enableMoveToFileCodeAction = true,
			autoUseWorkspaceTsdk = true,
			experimental = {
				maxInlayHintLength = 30,
				completion = {
					enableServerSideFuzzyMatch = true,
				},
			},
			javascript = {
				updateImportsOnFileMove = { enabled = "always" },
			},
		},
	},
}
-- Then enable it
vim.lsp.enable("vtsls", true)
-- Enable configured servers
-- vim.lsp.enable("lua_ls")
-- vim.lsp.enable("clangd")
-- vim.lsp.enable("gopls")
-- vim.lsp.enable("html")
-- vim.lsp.enable("htmx")
-- vim.lsp.enable("nil_ls")
-- vim.lsp.enable("tailwindcss")
-- vim.lsp.enable("templ")
-- vim.lsp.enable("eslint")
-- vim.lsp.config("eslint", {
-- 	--- ...
-- 	on_attach = function(client, bufnr)
-- 		vim.api.nvim_create_autocmd("BufWritePre", {
-- 			buffer = bufnr,
-- 			command = "EslintFixAll",
-- 		})
-- 	end,
-- })
