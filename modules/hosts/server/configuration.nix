{ inputs, ... }:
{
  flake.modules.nixos.server = {
    imports = with inputs.self.modules.nixos; [ system-cli ];
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "server";
}
