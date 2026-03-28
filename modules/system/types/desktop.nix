{ inputs, lib, ... }:
# expansion of cli system for desktop use
{
  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      windowmanager
      dev
    ];
  };

  flake.modules.darwin.system-desktop = {
    imports = with inputs.self.modules.darwin; [
      system-cli
      settings
      windowmanager
      dev
    ];
  };

  flake.modules.homeManager.system-desktop = {
    imports = with inputs.self.modules.homeManager; [
      system-cli
      windowmanager
      browser
      dev
      cloud-connection
      desktop-util
    ];
  };
}
