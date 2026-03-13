vim.lsp.enable({ "lua_ls", "gopls", "html", "denolsp", "pyright", "templ", "clangd", "nixd", "tailwindcss" })

vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.diagnostic.config({
	signs = { priority = 9999, severity = { min = "WARN", max = "ERROR" } },
	underline = { severity = { min = "HINT", max = "ERROR" } },
	virtual_lines = false,
	virtual_text = {
		current_line = true,
		severity = { min = "ERROR", max = "ERROR" },
	},
	update_in_insert = false,
})

-- Formatting
local function is_deno_project()
	return vim.fs.root(0, { "deno.json", "deno.jsonc", "deno.lock" }) ~= nil
end

local function js_formatters()
	if is_deno_project() then
		return { "deno_fmt" }
	end
	return { "prettierd", "prettier", stop_after_first = true }
end

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixfmt" },
		go = { "gofumpt" },
		python = { "black" },
		typescript = js_formatters,
		typescriptreact = js_formatters,
		javascript = js_formatters,
		javascriptreact = js_formatters,
		json = js_formatters,
		html = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		templ = { "templ" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

-- Linting
local lint = require("lint")

lint.linters_by_ft = {
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	go = { "golangcilint" },
	python = { "ruff" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
	callback = function()
		if vim.api.nvim_buf_get_name(0) == "" then
			return
		end
		local ft = vim.bo.filetype
		-- deno handled by LSP, skip eslint_d for deno projects
		if vim.tbl_contains({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, ft) then
			if not is_deno_project() then
				lint.try_lint()
			end
		else
			lint.try_lint()
		end
	end,
})
