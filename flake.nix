{
  description = "neovim — self-contained, Nix-managed";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  # nightly neovim: pkgs.neovim in mkNeovim becomes the nix-community nightly
  # build (binary cache: nix-community.cachix.org)
  inputs.neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

  outputs = { self, nixpkgs, ... }:
    let
      systems      = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor      = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.inputs.neovim-nightly-overlay.overlays.default ];
      };
    in {
      lib = import ./lib { inputs = self.inputs; inherit pkgsFor; };

      packages = forAllSystems (system: {
        # live config: nix provides the binary, plugins and tools;
        # the lua config is read from ~/.config/nvim at startup
        default   = self.lib.mkNeovim { inherit system; };
        neovim    = self.lib.mkNeovim { inherit system; };
        # config snapshot baked into the store (old behavior)
        standalone = self.lib.mkNeovim { inherit system; embedConfig = true; };
        vimPlugin = self.lib.mkVimPlugin { inherit system; };
      });

      apps = forAllSystems (system: {
        default = {
          type    = "app";
          program = "${self.packages.${system}.neovim}/bin/nvim";
        };
        nvim = {
          type    = "app";
          program = "${self.packages.${system}.neovim}/bin/nvim";
        };
      });

      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          buildInputs = [ (pkgsFor system).just ];
        };
      });

      formatter = forAllSystems (system: (pkgsFor system).alejandra);
    };
}
