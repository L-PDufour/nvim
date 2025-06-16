local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixfmt" },
		-- typescript = { "prettierd", "prettier" },
		-- typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		-- javascript = { "prettierd", "prettier", stop_after_first = true },
		-- javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		-- json = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		templ = { "templ" },
	},
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})
local lint = require("lint")

-- Configure linters by filetype
lint.linters_by_ft = {
	-- javascript = { "eslint_d" },
	-- javascriptreact = { "eslint_d" },
	-- typescript = { "eslint_d" },
	-- typescriptreact = { "eslint_d" },
	-- markdown = { "vale" }, -- If you have vale installed
	-- You can add more linters here
	-- python = {'pylint', 'mypy'},
	-- lua = {'luacheck'},
}

-- Setup autocmd to trigger linting
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
	callback = function()
		-- Only lint if the buffer has a name (not for scratch buffers)
		if vim.api.nvim_buf_get_name(0) ~= "" then
			require("lint").try_lint()
		end
	end,
})

-- lint.linters.eslint_d = require("lint.linters.eslint_d")
-- You can customize the linter if needed:
-- lint.linters.eslint_d.args = {
--   '--no-warn-ignored',
--   '--format', 'json',
--   '--stdin',
--   '--stdin-filename', function() return vim.api.nvim_buf_get_name(0) end,
-- }
