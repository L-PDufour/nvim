-- Servers whose executable may not exist on a non-Nix install (project
-- toolchains, OpenBSD ports). Attaching to a missing command only produces
-- spawn errors, so skip those servers up front. html/cssls resolve their
-- command lazily and fall back to project-local node_modules/.bin, so they are
-- left enabled unconditionally.
local servers = {
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
}

local server_commands = {
	lua_ls = "lua-language-server",
	golangci_lint_ls = "golangci-lint-langserver",
	gopls = "gopls",
	pyright = "pyright-langserver",
	templ = "go",
	clangd = "clangd",
	nixd = "nixd",
	tailwindcss = "tailwindcss-language-server",
	tsc = "tsc",
	biome = "biome",
}

local available_servers = {}
for _, name in ipairs(servers) do
	local cmd = server_commands[name]
	if not cmd or vim.fn.executable(cmd) == 1 then
		table.insert(available_servers, name)
	end
end
vim.lsp.enable(available_servers)

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
local formatters_by_ft = {
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
}

-- A non-Nix install (OpenBSD) may lack some of these binaries. Pruning them
-- here keeps format-on-save from erroring on every write; conform would
-- otherwise report "formatter not found".
for ft, names in pairs(formatters_by_ft) do
	local kept = {}
	for _, name in ipairs(names) do
		-- The templ formatter shells out to `go tool templ`.
		local exe = name == "templ" and "go" or name
		if vim.fn.executable(exe) == 1 then
			table.insert(kept, name)
		end
	end
	formatters_by_ft[ft] = #kept > 0 and kept or nil
end

require("conform").setup({
	formatters = {
		-- Use the project-pinned binary (requires the `go get -tool` directive).
		templ = {
			command = "go",
			prepend_args = { "tool", "templ" },
			cwd = require("conform.util").root_file({ "go.mod", "go.work" }),
		},
	},
	formatters_by_ft = formatters_by_ft,
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

-- Linting: JS/TS diagnostics come from the biome LSP, so nvim-lint only
-- covers python here. Skip linters whose binary is not installed (OpenBSD
-- ports may not ship ruff) instead of warning on every save.
local lint = require("lint")

lint.linters_by_ft = {}
if vim.fn.executable("ruff") == 1 then
	lint.linters_by_ft.python = { "ruff" }
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
	callback = function()
		if vim.api.nvim_buf_get_name(0) == "" then
			return
		end
		lint.try_lint()
	end,
})
