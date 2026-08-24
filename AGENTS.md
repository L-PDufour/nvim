# AGENTS.md

Nvim config backed by Nix. **The Lua is loaded live from this checkout** — you
edit a file under `lua/` or `after/` and restart nvim; there is no build or
rebuild step for Lua changes. Do not expect `nix build`/flake changes to take
effect locally — those live in the external `nixcfg` repo and need a system
rebuild there.

## Two-layer ownership (read before editing)

- **This repo (Lua)**: everything under `lua/`, `after/`, `init.lua`,
  `after/ftplugin/`, `after/snippets/`. Edit freely, restart nvim.
- **Nix (not this repo)**: `flake.nix` + `lib/default.nix` declare plugins,
  formatters/linters, debug adapters, LSP binaries, and the nvim binary. To
  add/remove a plugin or tool, edit `lib/default.nix` and rebuild in `nixcfg`
  (`nix flake update nvim`) — never assume a change here shows up at runtime.

`lib/default.nix` `mkNeovim` has two modes: `embedConfig=false` (default =
live config, this checkout) and `embedConfig=true` (standalone snapshot).

## Layout / wiring

- `init.lua` → `require("config")` → `lua/config/init.lua`, which sets the
  leader and `_G.Config` (with a shared autocmd helper) and loads modules in a
  fixed order at lines 26-42. **New feature modules must be `require`d there**
  (or pulled in via lazydev/plenary — there is no lazy loader; plugins come
  preloaded from Nix). A new `lua/config/<name>.lua` is *not* loaded by path.
- **LSP split**: `lua/config/lsp.lua` calls `vim.lsp.enable({...})` with the
  server names. Per-server settings go in matching `after/lsp/<name>.lua`
  files returned as `vim.lsp.Config` tables (auto-loaded by enabled name).
  Buffer-agnostic defaults use `vim.lsp.config("*")` in `lsp.lua`. Conform
  (formatters) and nvim-lint config also live in `lsp.lua`.
- **Project-sensitive servers** (gopls, clangd, ts_ls, pyright, rust-analyzer)
  are *not* installed here — they come from each project's own devShell. Only
  editor-adjacent servers (lua, nixd, marksman) ship with nvim. Don't add
  project LSP binaries to `mkExtraPackages`.

## Formatting / linting / diagnostics

- Formatters via conform on save: `lua`→stylua, `nix`→nixfmt, `go`→gofumpt,
  `python`→black, JS/TS→prettierd, `templ`→templ. Linters via nvim-lint:
  eslint_d (JS/TS, skipped for deno projects) and ruff (python). All binaries
  provided by the Nix wrapper PATH.
- Format Lua with `stylua` (already on PATH). `.luarc.json` configures
  lua-language-server (LuaJIT runtime, `diagnostics.globals` = vim/map/require).
- `git`-formatting of Nix files uses alejandra (`nix fmt`, flake formatter),
  and the dev shell provides `just`. `.gitignore` excludes `after/syntax`
  (generated), `/.direnv`, `/result`.

## AI config

- `lua/config/ai.lua` drives CodeCompanion: **deepseek** (direct HTTP) is the
  chat default — API key at `~/.config/deepseek/api_key` (`chmod 600`, no
  `.env` support). **opencode** backend runs the `opencode` CLI over Agent
  Client Protocol for repo-level questions; authenticate with
  `opencode auth login`. Prompts live in `ai.lua` and can be edited live.

## Workflow / gotchas

- Scratch configs: `NVIM_APPNAME=nvim-test nvim` isolates a copy under
  `~/.config/nvim-test` (respected via `stdpath`). Useful to test changes
  without touching your real config.
- `after/ftplugin/*.lua` and `after/snippets/` load by filetype — filetype
  changes require the matching autocmd, not manual requires.
- Emacs-style workflows (`:Compile`/`:Recompile`, scratch buffers,
  embark-act at `g.`) are defined in `lua/config/{compile,snacks,act}.lua`.
- Hotpot/Fennel is an optional future add-on: requires uncommenting
  `hotpot-nvim` in `mkNeovimPlugins` + a rebuild, then `require("hotpot")`
  at the top of `init.lua`; `.fnl` files compile on the fly.
