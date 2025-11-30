vim.lsp.enable({ "lua_ls", "gopls", "html", "denolsp", "pyright", "templ", "clangd", "nixd", "tailwindcss" })
local diagnostic_opts = {
	-- Show signs on top of any other sign, but only for warnings and errors
	signs = { priority = 9999, severity = { min = "WARN", max = "ERROR" } },

	-- Show all diagnostics as underline (for their messages type `<Leader>ld`)
	underline = { severity = { min = "HINT", max = "ERROR" } },

	-- Show more details immediately for errors on the current line
	virtual_lines = false,
	virtual_text = {
		current_line = true,
		severity = { min = "ERROR", max = "ERROR" },
	},

	-- Don't update diagnostics when typing
	update_in_insert = false,
}

-- Use `later()` to avoid sourcing `vim.diagnostic` on startup
vim.diagnostic.config(diagnostic_opts)
local conform = require("conform")

local function is_deno_project()
	local deno_files = { "deno.json", "deno.jsonc", "mod.ts", "deps.ts" }
	for _, file in ipairs(deno_files) do
		if vim.fn.filereadable(vim.fn.getcwd() .. "/" .. file) == 1 then
			return true
		end
	end
	return false
end

-- Helper function to get appropriate formatters based on project type
local function get_js_formatters()
	if is_deno_project() then
		return { "deno_fmt" }
	else
		return { "prettierd", "prettier", stop_after_first = true }
	end
end

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixfmt" },
		go = { "gofumpt" },
		python = { "black" },
		-- JavaScript/TypeScript - context-aware formatting
		typescript = get_js_formatters,
		typescriptreact = get_js_formatters,
		javascript = get_js_formatters,
		javascriptreact = get_js_formatters,
		json = function()
			if is_deno_project() then
				return { "deno_fmt" }
			else
				return { "prettierd", "prettier", stop_after_first = true }
			end
		end,
		html = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		templ = { "templ" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	-- Configure custom formatters
	formatters = {
		deno_fmt = {
			command = "deno",
			args = { "fmt", "-" },
			stdin = true,
		},
	},
})

local lint = require("lint")

-- Configure linters by filetype (using static tables, not functions)
-- We'll handle the dynamic selection in the autocmd instead
lint.linters_by_ft = {
	javascript = { "eslint_d" }, -- Default to Node.js, will be overridden for Deno
	javascriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	go = { "golangcilint" },
	python = { "ruff" }, -- or { "pylint", "mypy" } if you prefer
	-- lua = { "luacheck" }, -- Uncomment if you want Lua linting
	-- markdown = { "vale" }, -- Uncomment if you have vale installed
}

-- No need to configure custom deno_lint - it's built-in!

-- Setup autocmd to trigger linting with dynamic linter selection
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
	callback = function()
		-- Only lint if the buffer has a name (not for scratch buffers)
		if vim.api.nvim_buf_get_name(0) ~= "" then
			local ft = vim.bo.filetype

			-- Override linters for JS/TS files based on project type
			if vim.tbl_contains({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, ft) then
				if is_deno_project() then
					-- Temporarily override linters for Deno projects
					local original_linters = lint.linters_by_ft[ft]
					lint.linters_by_ft[ft] = { "deno" } -- Use built-in deno linter
					require("lint").try_lint()
					-- Restore original linters
					lint.linters_by_ft[ft] = original_linters
				else
					require("lint").try_lint()
				end
			else
				require("lint").try_lint()
			end
		end
	end,
})

-- Optional: Add commands for manual control
vim.api.nvim_create_user_command("ToggleDeno", function()
	local current_dir = vim.fn.getcwd()
	if is_deno_project() then
		print("Deno project detected in: " .. current_dir)
	else
		print("Node.js project detected in: " .. current_dir)
	end
end, { desc = "Check current project type" })

vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})
