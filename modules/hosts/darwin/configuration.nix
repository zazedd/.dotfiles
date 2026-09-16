{ inputs, ... }:
let
  hostname = "shitbook";
in
{
  flake.modules.darwin.${hostname} = {
    imports = with inputs.self.modules.darwin; [
      system-desktop
      gaming
      photography
      work
      jellyfin
    ];
    networking.hostName = hostname;

    homebrew = {
      enable = true;
    };
  };
}
