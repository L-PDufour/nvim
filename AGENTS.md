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

### Non-Nix installs (OpenBSD)

The same Lua also runs where there is no Nix. On startup `lua/config/init.lua`
checks `vim.g.nix_managed`:

- set by the Nix wrapper (`lib/default.nix`, both `liveInit` and the
  `embedConfig` branch) → plugins come from `packages.main.start`, nothing else
  happens;
- unset (OpenBSD, plain `nvim`) → `lua/plugins.lua` installs the same plugin
  set with Neovim 0.12's built-in `vim.pack`, pinned by `nvim-pack-lock.json`.

`lua/plugins.lua` mirrors `mkNeovimPlugins` in `lib/default.nix`; **keep the
two lists in sync**. Nix stays in charge on Linux (nothing is pruned from
there yet). Because ports differ from the wrapper's PATH, `lsp.lua` prunes LSP
servers/formatters/linters whose binaries are missing, `dap.lua` skips adapters
that are not installed, and treesitter parsers are only installed when the
`tree-sitter` CLI exists (otherwise highlighting falls back to regex).

## Layout / wiring

- `init.lua` → `require("config")` → `lua/config/init.lua`, which sets the
  leader and `_G.Config` (with a shared autocmd helper) and loads modules in a
  fixed order at lines 26-42. **New feature modules must be `require`d there**
  (or pulled in via lazydev/plenary — there is no lazy loader; plugins are
  preloaded from Nix, or by `vim.pack` on non-Nix installs). A new
  `lua/config/<name>.lua` is *not* loaded by path.
- **LSP split**: `lua/config/lsp.lua` calls `vim.lsp.enable({...})` with the
  server names. Per-server settings go in matching `after/lsp/<name>.lua`
  files returned as `vim.lsp.Config` tables (auto-loaded by enabled name).
  Buffer-agnostic defaults use `vim.lsp.config("*")` in `lsp.lua`. Conform
  (formatters) and nvim-lint config also live in `lsp.lua`.
- **Project-sensitive servers** (gopls, clangd, pyright, rust-analyzer, `tsc`)
  are *not* installed here — they come from each project's own devShell. Only
  editor-adjacent servers (lua, nixd, marksman) ship with nvim. Don't add
  project LSP binaries to `mkExtraPackages`.

## Formatting / linting / diagnostics

- Formatting via conform on save: `lua`→stylua, `nix`→nixfmt, `go`→gofumpt,
  `python`→black, JS/TS/JSON/CSS/HTML→biome, `templ`→templ. JS/TS diagnostics
  come from the `biome` LSP (`biome lsp-proxy`); nvim-lint only runs ruff for
  python. All binaries provided by the Nix wrapper PATH (`biome` is in
  `mkExtraPackages`).
- Format Lua with `stylua` (already on PATH). `.luarc.json` configures
  lua-language-server (LuaJIT runtime, `diagnostics.globals` = vim/map/require).
- `git`-formatting of Nix files uses alejandra (`nix fmt`, flake formatter),
  and the dev shell provides `just`. `.gitignore` excludes `after/syntax`
  (generated), `/.direnv`, `/result`.

## Debugging

- `lua/config/dap.lua` declares **adapters only**; launch configurations come
  from each project's `.vscode/launch.json`, read automatically by nvim-dap
  (`:help dap-providers`). The UI is `nvim-dap-view` (single shared window,
  winbar keymap hints); Go/Python defaults come from `nvim-dap-go` /
  `nvim-dap-python`. C/C++ uses `lldb-dap` (from the `lldb` Nix package);
  JS/TS uses `js-debug` (`pwa-node`/`pwa-chrome`/`node`/`chrome`).

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
- Offline docs: `lua/config/devdocs.lua` sets up `devdocs.nvim`
  (`<leader>h` group); docs download to `stdpath("data")/devdocs`.
- Hotpot/Fennel is an optional future add-on: requires uncommenting
  `hotpot-nvim` in `mkNeovimPlugins` + a rebuild, then `require("hotpot")`
  at the top of `init.lua`; `.fnl` files compile on the fly.
