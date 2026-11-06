---@brief
---
--- https://pg-language-server.com
---
--- Postgres Language Server: syntax diagnostics from Postgres' own parser,
--- type checking against the schema, completion, formatting, linting.
---
--- It reads `postgres-language-server.jsonc` from the workspace root, which
--- is where the database connection lives — one file per project:
---
---   {
---     "db": { "connectionString": "postgres://me@localhost:5432/app?sslmode=disable" },
---     "linter": { "enabled": true, "groups": { "typecheck": "error" } }
---   }
---
--- `postgres-language-server init` writes a starting file. Type checking is
--- skipped without a reachable connection, and the schema is read when the
--- client starts: `:LspRestart postgres_lsp` after a migration.
---
--- `workspace_required` keeps it out of files that belong to no project;
--- drop `".git"` to make it attach in repos that are not Postgres projects.
return {
	cmd = { "postgres-language-server", "lsp-proxy" },
	filetypes = { "sql" },
	root_markers = { "postgres-language-server.jsonc", ".git" },
	workspace_required = true,
}
