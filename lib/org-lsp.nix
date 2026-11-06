# org-lsp: the Org language server (Rust) and the Neovim plugin that drives it.
#
# Both come from the same tag, so the plugin and the server agree on the
# protocol and the command set. The server is the only piece the plugin needs
# from Nix: `server_command()` checks a build in the plugin's own directory,
# then `org-lsp` on PATH, and only then downloads a release.
{ pkgs }:
let
  inherit (pkgs) lib;
  version = "0.1.5";

  src = pkgs.fetchFromGitHub {
    owner = "kristijanhusak";
    repo = "org-lsp";
    tag = "v${version}";
    # from `nix store prefetch-file --unpack` on the v0.1.5 archive
    hash = "sha256-X/9eq/JqADPes6hLO9CR0O4b6lX+A3nUKNZz1By56sU=";
  };
in
{
  inherit src version;

  server = pkgs.rustPlatform.buildRustPackage {
    pname = "org-lsp";
    inherit version src;

    # Cargo.lock ships in the tag, so there is no cargoHash to update.
    cargoLock.lockFile = "${src}/Cargo.lock";
    # The workspace root is a virtual manifest with four members
    # (org-syntax, org-core, org-lsp, site): build the server alone.
    cargoBuildFlags = [ "-p" "org-lsp" ];
    # Tests compare against Emacs-generated fixtures and the whole corpus.
    doCheck = false;

    meta = {
      description = "Language server for Org mode";
      homepage = "https://github.com/kristijanhusak/org-lsp";
      license = lib.licenses.gpl3Plus;
      mainProgram = "org-lsp";
    };
  };

  plugin = pkgs.vimUtils.buildVimPlugin {
    pname = "org-lsp";
    inherit version src;
    doCheck = false;
    # Neovim loads plugin/, lua/ and syntax/; editors/vim/syntax/org.vim is
    # sourced by syntax/org.vim, so it stays. The rest builds the server, the
    # documentation, or other editors' integrations.
    postInstall = ''
      rm -rf $out/{server,site,docs,tests,scripts,.claude,.github}
      rm -rf $out/editors/{vscode,sublime,zed,helix,neovim}
      rm -f $out/{Cargo.toml,Cargo.lock,CLAUDE.md,README.org,rustfmt.toml}
    '';
  };
}
