{
  description = "neovim — self-contained, Nix-managed";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      lib = import ./lib {
        inputs = self.inputs;
        inherit pkgsFor;
      };
      packages = forAllSystems (system: {
        default = self.lib.mkVimPlugin { inherit system; };
        neovim = self.lib.mkNeovim { inherit system; };
      });
      apps = forAllSystems (system: {
        nvim = {
          program = "${self.packages.${system}.neovim}/bin/nvim";
          type = "app";
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
