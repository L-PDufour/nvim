# nvim

Neovim with the binary, plugins, LSPs, formatters and debug adapters
managed by Nix, and the Lua config loaded **live** from `~/.config/nvim`.

## Setup

Clone this repo to the standard config location:

```bash
git clone https://github.com/L-PDufour/nvim ~/.config/nvim
```

That's it. The Nix-built `nvim` (installed via the `nvim` flake input in
[nixcfg](https://github.com/L-PDufour/nixcfg)) looks for
`stdpath("config")/init.lua` at startup and loads it directly — edit any
file under `~/.config/nvim`, restart nvim, done. No rebuild, no flake
update, and the checkout is a plain git repo you commit to like any
dotfiles.

## What Nix still owns

Everything except the Lua files — declared in `lib/default.nix`:

- **plugins** (`mkNeovimPlugins`): add/remove plugins here, then rebuild
  the system (or `nix flake update nvim` in nixcfg first if the change is
  already pushed)
- **tools on `nvim`'s PATH** (`mkExtraPackages`): formatters, linters,
  debug adapters, editor-adjacent LSPs
- **the binary itself** and its wrapper flags

## Package outputs

| output | behavior |
|---|---|
| `default` / `neovim` | live config from `~/.config/nvim`, falls back to the snapshot baked at build time when no checkout exists (so `nix run github:L-PDufour/nvim` works anywhere) |
| `standalone` | config snapshot fully baked into the store (the old behavior — fully reproducible, rebuild per edit) |
| `vimPlugin` | this repo's config packaged as a vim plugin |

`stdpath("config")` respects `NVIM_APPNAME`, so you can test a scratch
config with `NVIM_APPNAME=nvim-test nvim` without touching the main one.

## Trying fennel later

Because the config is loaded live, adding [Fennel](https://fennel-lang.org/)
needs exactly one Nix change: uncomment `hotpot-nvim` in
`mkNeovimPlugins` (`lib/default.nix`) and rebuild once. After that,
bootstrap it at the top of `init.lua`:

```lua
require("hotpot")
```

and any `fnl/**/*.fnl` file in this repo becomes `require`-able —
hotpot compiles Fennel to Lua on the fly and caches the result, so
iteration stays instant with no further Nix involvement. (Alternative:
`nfnl`, which compiles `.fnl` to committed `.lua` files on save instead.)
