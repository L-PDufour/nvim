vim.lsp.enable({
	"lua_ls",
	"golangci_lint_ls",
	"gopls",
	"html",
	"denolsp",
	"pyright",
	"templ",
	"clangd",
	"nixd",
	"tailwindcss",
	"cssls",
})

vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- templ proxies this notification verbatim to its internal gopls, which
-- otherwise never learns about edits to plain .go files (they aren't
-- attached to the templ client). The OS file watcher should cover this,
-- but is unreliable on Linux, so push the event ourselves on save.
Config.autocmd("BufWritePost", "*.go", function(ev)
	local fname = vim.api.nvim_buf_get_name(ev.buf)
	for _, client in ipairs(vim.lsp.get_clients({ name = "templ" })) do
		client:notify("workspace/didChangeWatchedFiles", {
			changes = { { uri = vim.uri_from_fname(fname), type = 2 } }, -- 2 = Changed
		})
	end
end, "Notify templ LSP about Go file changes")
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
		templ = { "got tool templ fmt" },
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
