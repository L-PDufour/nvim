{ inputs, pkgsFor }:
rec {
  mkVimPlugin =
    { system }:
    let
      pkgs = pkgsFor system;
    in
    pkgs.vimUtils.buildVimPlugin {
      name = "config";
      src = ../.;
      doCheck = false;
      postInstall = ''
        rm -rf $out/flake.nix $out/flake.lock $out/lib
      '';
    };

  mkNeovimPlugins =
    { system }:
    let
      pkgs = pkgsFor system;
    in
    with pkgs.vimPlugins;
    [
      # core
      plenary-nvim
      nvim-treesitter.withAllGrammars
      mini-nvim
      snacks-nvim
      which-key-nvim
      flash-nvim
      base16-nvim

      # editing / completion
      blink-cmp
      blink-ripgrep-nvim
      friendly-snippets
      lazydev-nvim
      undotree

      # lint / format
      nvim-lint
      conform-nvim

      # dap
      nvim-dap
      nvim-dap-ui
      nvim-nio
      nvim-dap-go
      nvim-dap-lldb
      nvim-dap-vscode-js
      nvim-dap-python
      nvim-dap-virtual-text

      # db
      vim-dadbod
      vim-dadbod-completion
      vim-dadbod-ui

      # misc
      orgmode
      headlines-nvim
      devdocs-nvim
      quicker-nvim
      overseer-nvim

      vim-tmux-navigator

      # your config as a plugin — loaded last
      (mkVimPlugin { inherit system; })
    ];

  mkExtraPackages =
    { system }:
    let
      pkgs = pkgsFor system;
    in
    with pkgs;
    [
      # runtime deps
      tree-sitter
      jq
      curl
      pandoc
      bat
      # inotifywait backend for vim.lsp file watching (libuv-watchdirs
      # fallback has known performance issues)
      inotify-tools

      # formatters (conform)
      stylua
      black
      prettierd
      templ
      gofumpt
      nixfmt

      # debug adapters (dap)
      delve
      lldb # provides lldb-dap
      vscode-js-debug
      (python3.withPackages (ps: [ ps.debugpy ]))

      # lsp — editor-adjacent, version-insensitive
      lua-language-server
      nixd
      marksman
      # project-sensitive servers (gopls, clangd, rust-analyzer, ts_ls, pyright)
      # come from project devShells
    ];

  mkNeovim =
    { system }:
    let
      pkgs = pkgsFor system;
      configPlugin = mkVimPlugin { inherit system; };
    in
    pkgs.neovim.override {
      configure = {
        customRC = ''
          luafile ${configPlugin}/init.lua
        '';
        packages.main.start = mkNeovimPlugins { inherit system; };
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${pkgs.lib.makeBinPath (mkExtraPackages { inherit system; })}"'';
      withPython3 = false;
      withNodeJs = false;
      withRuby = false;
    };
}
