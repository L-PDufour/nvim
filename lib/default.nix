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
      catppuccin-nvim

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

      # ai (config in lua/config/ai.lua)
      codecompanion-nvim

      # misc
      orgmode
      headlines-nvim
      devdocs-nvim
      quicker-nvim
      overseer-nvim

      vim-tmux-navigator

      # fennel — uncomment when ready to try it: write .fnl files under
      # fnl/ in the live config and hotpot compiles them on the fly
      # hotpot-nvim
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
    {
      system,
      # true  → bake the config snapshot from this repo into the store
      #         (fully reproducible, but every edit needs a rebuild)
      # false → load the config live from stdpath("config")
      #         (~/.config/nvim), falling back to the baked snapshot when
      #         no local checkout exists — so `nix run` works anywhere
      embedConfig ? false,
    }:
    let
      pkgs = pkgsFor system;
      configPlugin = mkVimPlugin { inherit system; };
      # The wrapper starts nvim with -u, which skips the user's init file
      # but leaves stdpath("config") on the runtimepath — so in live mode
      # lua/, after/ and plugin/ resolve natively and only init.lua needs
      # to be loaded by hand.
      liveInit = pkgs.writeText "live-init.lua" ''
        local user_init = vim.fn.stdpath("config") .. "/init.lua"
        if vim.fn.filereadable(user_init) == 1 then
          dofile(user_init)
        else
          vim.opt.rtp:prepend("${configPlugin}")
          vim.opt.rtp:append("${configPlugin}/after")
          dofile("${configPlugin}/init.lua")
        end
      '';
    in
    # neovim-nightly-overlay replaces pkgs.neovim with the (unwrapped) nightly
    # build, so wrap it ourselves instead of pkgs.neovim.override (which would
    # try to pass `configure` to the unwrapped derivation and fail).
    pkgs.wrapNeovim pkgs.neovim-unwrapped {
      configure = {
        customRC =
          if embedConfig then
            ''
              luafile ${configPlugin}/init.lua
            ''
          else
            ''
              luafile ${liveInit}
            '';
        packages.main.start =
          mkNeovimPlugins { inherit system; }
          ++ pkgs.lib.optional embedConfig configPlugin;
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${pkgs.lib.makeBinPath (mkExtraPackages { inherit system; })}"'';
      withPython3 = false;
      withNodeJs = false;
      withRuby = false;
    };
}
