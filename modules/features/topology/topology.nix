{ inputs, self, ... }:
{
  flake.modules.nixos.topology = {
    imports = [ inputs.nix-topology.nixosModules.default ];
  };

  flake.topology = inputs.nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
    system:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.nix-topology.overlays.default ];
      };
    in
    import inputs.nix-topology {
      inherit pkgs;
      modules = [
        {
          nixosConfigurations = self.nixosConfigurations;
        }
      ];
    }
  );
}
