vim.lsp.enable({
	"lua_ls",
	"golangci_lint_ls",
	"gopls",
	"html",
	"pyright",
	"templ",
	"clangd",
	"nixd",
	"tailwindcss",
	"cssls",
	"tsc",
	"biome",
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
require("conform").setup({
	formatters = {
		-- templ binary is no longer in the flake; use the module's copy via `go tool`
		templ = {
			command = "go",
			prepend_args = { "tool", "templ" },
			cwd = require("conform.util").root_file({ "go.mod", "go.work" }),
		},
	},
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixfmt" },
		go = { "gofumpt" },
		python = { "black" },
		-- biome is the only web formatter: it picks up the project's
		-- biome.json when present, otherwise formats with its defaults.
		typescript = { "biome" },
		typescriptreact = { "biome" },
		javascript = { "biome" },
		javascriptreact = { "biome" },
		json = { "biome" },
		jsonc = { "biome" },
		css = { "biome" },
		html = { "biome" },
		templ = { "templ" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

-- Linting: JS/TS diagnostics come from the biome LSP, so nvim-lint only
-- covers python here.
local lint = require("lint")

lint.linters_by_ft = {
	python = { "ruff" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
	callback = function()
		if vim.api.nvim_buf_get_name(0) == "" then
			return
		end
		lint.try_lint()
	end,
})
