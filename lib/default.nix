{ inputs, pkgsFor }:
let
in
rec {
  mkVimPlugin =
    { system }:
    let
      pkgs = pkgsFor system;
      inherit (pkgs.vimUtils) buildVimPlugin;
    in
    buildVimPlugin {
      name = "config";
      src = ../.;
      doCheck = false;
      postInstall = ''
        rm -rf $out/flake.nix
        rm -rf $out/flake.lock
        rm -rf $out/lib
        rm -rf $out/package.nix
      '';
    };

  mkNeovimPlugins =
    { system }:
    let
      pkgs = pkgsFor system;
      configPlugin = mkVimPlugin { inherit system; };
    in
    with pkgs.vimPlugins;
    [
      plenary-nvim
      nvim-treesitter.withAllGrammars
      mini-nvim
      nvim-lint
      friendly-snippets
      conform-nvim
      undotree
      blink-cmp
      blink-ripgrep-nvim
      orgmode
      headlines-nvim
      lazydev-nvim
      catppuccin-nvim
      snacks-nvim
      devdocs-nvim
      which-key-nvim
      flash-nvim
      nvim-dap
      nvim-dap-ui
      nvim-nio
      nvim-dap-go
      nvim-dap-lldb
      nvim-dap-vscode-js
      nvim-dap-python
      nvim-dap-virtual-text
      vim-dadbod
      vim-dadbod-completion
      vim-dadbod-ui
      oil-nvim
      quicker-nvim
      overseer-nvim
      everforest
      gruvbox-material-nvim
      vim-tmux-navigator
      # your config as a plugin — loaded last
      configPlugin
    ];

  mkExtraPackages =
    { system }:
    let
      pkgs = pkgsFor system;
    in
    with pkgs;
    [
      tree-sitter
      jq
      curl
      pandoc
      bat
    ];

  mkNeovim =
    { system }:
    let
      pkgs = pkgsFor system;
      configPlugin = mkVimPlugin { inherit system; };
      start = mkNeovimPlugins { inherit system; };
      extraPackages = mkExtraPackages { inherit system; };
    in
    pkgs.neovim.override {
      configure = {
        customRC = ''
          luafile ${configPlugin}/init.lua
        '';
        packages.main = { inherit start; };
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${pkgs.lib.makeBinPath extraPackages}"'';
      withPython3 = false;
      withNodeJs = false;
      withRuby = false;
    };
}
