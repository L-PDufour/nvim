---@brief
---
--- https://biomejs.dev
---
--- Biome's own language server, started as `biome lsp-proxy`. The `biome`
--- binary is provided on `$PATH` by the flake. Formatting is handled
--- separately by conform's `biome` formatter.
---
--- ### Monorepo support
---
--- `biome` finds the `biome.json` for the package being edited, so a single
--- server instance covers the whole monorepo.

---@type vim.lsp.Config
return {
	cmd = { "biome", "lsp-proxy" },
	filetypes = {
		"astro",
		"css",
		"graphql",
		"html",
		"javascript",
		"javascriptreact",
		"json",
		"jsonc",
		"svelte",
		"typescript",
		"typescriptreact",
		"vue",
	},
	workspace_required = true,
	root_dir = function(bufnr, on_dir)
		local root_markers = {
			"package-lock.json",
			"yarn.lock",
			"pnpm-lock.yaml",
			"bun.lockb",
			"bun.lock",
		}
		local biome_config_files = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }
		root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers, biome_config_files, { ".git" } }
			or vim.list_extend(root_markers, vim.list_extend(biome_config_files, { ".git" }))

		-- Fall back to the cwd when no project root is found.
		local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

		-- Only attach when the buffer is actually part of a biome project.
		local filename = vim.api.nvim_buf_get_name(bufnr)
		local is_buffer_using_biome = vim.fs.find(biome_config_files, {
			path = filename,
			type = "file",
			limit = 1,
			upward = true,
			stop = vim.fs.dirname(project_root),
		})[1]
		if not is_buffer_using_biome then
			return
		end

		on_dir(project_root)
	end,
}
