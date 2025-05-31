-- Set up LSP in lua/user/lsp.lua for Neovim 0.11+
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- Configure diagnostics globally
vim.diagnostic.config({
	virtual_text = {
		prefix = "■ ",
	},
	float = { border = "rounded" },
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN] = "W",
			[vim.diagnostic.severity.INFO] = "I",
			[vim.diagnostic.severity.HINT] = "H",
		},
	},
})

-- Then enable the servers
vim.lsp.enable("vtsls")
vim.lsp.enable("gopls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("html")
-- vim.lsp.enable("htmx")
vim.lsp.enable("templ")
vim.lsp.enable("nixd")
vim.lsp.enable("tailwindcss")
