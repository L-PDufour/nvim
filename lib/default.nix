{ inputs, ... }:
let
  inherit (inputs.nixpkgs) legacyPackages;
in
rec {
  # Plugin builder function
  mkVimPlugin =
    { system }:
    let
      inherit (pkgs) vimUtils;
      inherit (vimUtils) buildVimPlugin;
      pkgs = legacyPackages.${system};
    in
    buildVimPlugin {
      name = "user";
      postInstall = ''
        rm -rf $out/.envrc
        rm -rf $out/.gitignore
        rm -rf $out/LICENSE
        rm -rf $out/README.md
        rm -rf $out/flake.lock
        rm -rf $out/default.nix
        rm -rf $out/flake.nix
        rm -rf $out/justfile
      '';
      src = ../.;
      doCheck = false;
      neovimRequireCheck = false;
    };

  # Core plugin list organized by functionality
  mkNeovimPlugins =
    { system }:
    let
      inherit (pkgs) vimPlugins;
      pkgs = legacyPackages.${system};
      user-nvim = mkVimPlugin { inherit system; };
    in
    [
      # Core functionality
      vimPlugins.plenary-nvim # Required by many plugins
      vimPlugins.which-key-nvim # Key binding helper
      vimPlugins.trouble-nvim
      vimPlugins.lazydev-nvim
      vimPlugins.mini-nvim # Collection of minimal plugins
      vimPlugins.better-escape-nvim
      vimPlugins.nvim-web-devicons
      vimPlugins.snacks-nvim
      vimPlugins.flash-nvim
      # LSP and Completion
      vimPlugins.blink-cmp
      vimPlugins.blink-pairs
      vimPlugins.blink-cmp-conventional-commits
      vimPlugins.blink-ripgrep-nvim
      vimPlugins.blink-cmp-spell
      vimPlugins.luasnip

      vimPlugins.friendly-snippets
      vimPlugins.conform-nvim
      vimPlugins.typescript-tools-nvim

      # Navigation and Search
      vimPlugins.harpoon2

      # Git Integration
      vimPlugins.gitsigns-nvim
      vimPlugins.diffview-nvim

      # Syntax and Language Support
      vimPlugins.nvim-treesitter.withAllGrammars
      vimPlugins.nvim-treesitter-textobjects
      vimPlugins.nvim-treesitter-parsers.c
      vimPlugins.nvim-treesitter-parsers.regex
      vimPlugins.nvim-treesitter-parsers.markdown
      vimPlugins.nvim-treesitter-parsers.markdown_inline
      vimPlugins.nvim-treesitter-parsers.css
      vimPlugins.nvim-treesitter-parsers.lua
      vimPlugins.nvim-treesitter-parsers.vim
      vimPlugins.nvim-treesitter-parsers.tsx
      vimPlugins.nvim-treesitter-parsers.javascript
      vimPlugins.nvim-treesitter-parsers.typescript
      vimPlugins.nvim-treesitter-parsers.go
      vimPlugins.nvim-treesitter-parsers.sql
      vimPlugins.nvim-treesitter-parsers.nix
      vimPlugins.nvim-treesitter-parsers.rust
      vimPlugins.nvim-treesitter-parsers.html
      vimPlugins.nvim-treesitter-parsers.bash
      vimPlugins.nvim-treesitter-parsers.templ
      vimPlugins.nvim-treesitter-parsers.python

      # UI and Aesthetics
      vimPlugins.catppuccin-nvim

      # Productivity Tools
      vimPlugins.undotree
      vimPlugins.orgmode
      vimPlugins.headlines-nvim

      # User config
      user-nvim

    ];

  # External tooling and language servers
  mkExtraPackages =
    { system }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    [
      # Language Servers
      pkgs.gopls
      pkgs.htmx-lsp
      pkgs.lua-language-server
      pkgs.nil
      pkgs.vtsls
      pkgs.nodejs_24
      pkgs.tailwindcss-language-server
      pkgs.typescript-language-server
      pkgs.vscode-langservers-extracted
      pkgs.nodePackages_latest.eslint_d
      pkgs.eslint

      # Formatters and Linters
      pkgs.nixfmt-rfc-style
      pkgs.nodePackages_latest.prettier
      pkgs.prettierd
      pkgs.stylua

      # Tools
      pkgs.python3
      pkgs.ripgrep
      pkgs.templ
    ];

  mkExtraConfig = ''
    lua << EOF
      require("user")
      vim.cmd("set runtimepath+=./ftplugin")
    EOF
  '';

  # Neovim builder
  mkNeovim =
    { system }:
    let
      inherit (pkgs) lib neovim;
      extraPackages = mkExtraPackages { inherit system; };
      pkgs = legacyPackages.${system};
      start = mkNeovimPlugins { inherit system; };
    in
    neovim.override {
      configure = {
        customRC = mkExtraConfig;
        packages.main = {
          inherit start;
        };
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${lib.makeBinPath extraPackages}"'';
    };

  # Home Manager integration
  mkHomeManager =
    { system }:
    let
      extraConfig = mkExtraConfig;
      extraPackages = mkExtraPackages { inherit system; };
      plugins = mkNeovimPlugins { inherit system; };
    in
    {
      inherit extraConfig extraPackages plugins;
      defaultEditor = true;
      enable = true;
    };
}
