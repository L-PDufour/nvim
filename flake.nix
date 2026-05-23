{
  description = "neovim — self-contained, Nix-managed";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems      = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor      = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      lib = import ./lib { inputs = self.inputs; inherit pkgsFor; };

      packages = forAllSystems (system: {
        default   = self.lib.mkNeovim { inherit system; };
        neovim    = self.lib.mkNeovim { inherit system; };
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
