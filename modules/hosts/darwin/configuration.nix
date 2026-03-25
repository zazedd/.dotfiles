{ inputs, ... }:
let
  hostname = "shitbook";
in
{
  flake.modules.darwin.${hostname} = {
    imports = with inputs.self.modules.darwin; [
      system-desktop
    ];
    networking.hostName = hostname;

    homebrew = {
      enable = true;
    };
  };
}
