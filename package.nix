{ pkgs, ... }:

let
  plugins = with pkgs.vimPlugins; [
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
  ];

  extraPackages = with pkgs; [
    tree-sitter
    jq
    curl
    pandoc
    bat
  ];

  configDir = pkgs.stdenv.mkDerivation {
    name = "nvim-config";
    src  = ./.;
    installPhase = ''
      mkdir -p $out
      cp -r init.lua lua after $out/
    '';
  };

in
  pkgs.wrapNeovim pkgs.neovim-unwrapped {
    withPython3 = false;
    withNodeJs  = false;
    withRuby    = false;

    configure = {
      packages.myNeovim.start = plugins;

      # Prepend bundled config to runtimepath, then source init.lua
      customRC = ''
        set runtimepath^=${configDir}
        set runtimepath+=${configDir}/after
        luafile ${configDir}/init.lua
      '';
    };

    extraMakeWrapperArgs = ''
      --prefix PATH : "${pkgs.lib.makeBinPath extraPackages}"
    '';
  }
