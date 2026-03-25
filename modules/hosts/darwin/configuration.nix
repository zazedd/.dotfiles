{ inputs, ... }:
let
  hostname = "shitbook";
in
{
  flake.modules.darwin.${hostname} = {
    imports = with inputs.self.modules.darwin; [
      zazed
      system-desktop
    ];
    networking.hostName = hostname;

    system.primaryUser = "zazed";
    homebrew = {
      enable = true;
    };

    home-manager.users.zazed = { };
  };

  flake.darwinConfigurations = inputs.self.lib.mkDarwin "aarch64-darwin" hostname;
}
