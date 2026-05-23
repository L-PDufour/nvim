{ inputs }:
let
  inherit (inputs.nixpkgs) legacyPackages;
in
rec {
  mkVimPlugin =
    { system }:
    let
      inherit (pkgs) vimUtils;
      inherit (vimUtils) buildVimPlugin;
      pkgs = legacyPackages.${system};
    in
    buildVimPlugin {
      buildInputs = with pkgs; [
        doppler
        nodejs
      ];
      name = "TheAltF4Stream";
      src = ../.;

      dependencies = with pkgs.vimPlugins; [
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
        fzf-lua
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
      ];

      nvimSkipModules = [
        "init"
        "notify.integrations.fzf"
      ];

      postInstall = ''
        rm -rf $out/.envrc
        rm -rf $out/.gitignore
        rm -rf $out/LICENSE
        rm -rf $out/README.md
        rm -rf $out/flake.lock
        rm -rf $out/flake.nix
        rm -rf $out/justfile
        rm -rf $out/lib
      '';
    };

  mkNeovimPlugins =
    { system }:
    let
      inherit (pkgs) vimPlugins;
      pkgs = legacyPackages.${system};
      thealtf4stream-nvim = mkVimPlugin { inherit system; };
    in
    with vimPlugins;
    [
      # languages
      vim-just
      zig-vim

      # floaterm
      vim-floaterm

      # extras
      image-nvim
      nvim-colorizer-lua
      nvim-web-devicons
      rainbow-delimiters-nvim
      trouble-nvim

      # configuration
      thealtf4stream-nvim
    ];

  mkExtraConfig = ''
    lua << EOF
      require 'TheAltF4Stream'.init()
    EOF
  '';

  mkNeovim =
    { system }:
    let
      inherit (pkgs) lib neovim;
      pkgs = legacyPackages.${system};
      start = mkNeovimPlugins { inherit system; };
    in
    neovim.override {
      configure = {
        customRC = mkExtraConfig;
        packages.main = { inherit start; };
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${lib.makeBinPath}"'';
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };

  mkHomeManager =
    { system }:
    let
      extraConfig = mkExtraConfig;
      plugins = mkNeovimPlugins { inherit system; };
    in
    {
      inherit extraConfig plugins;
      defaultEditor = true;
      enable = true;
      extraLuaPackages = ps: [ ps.magick ];
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };
}
