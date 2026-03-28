{ inputs, ... }:
# import all essential nix-tools which are used in all modules of a specific class
{
  flake.modules.nixos.system-default = {
    imports = with inputs.self.modules.nixos; [
      system-minimal

      home-manager
      secrets
    ];
  };

  flake.modules.darwin.system-default = {
    imports = with inputs.self.modules.darwin; [
      system-minimal

      home-manager
      homebrew
      secrets
    ];
  };

  flake.modules.homeManager.system-default = {
    imports = with inputs.self.modules.homeManager; [
      system-minimal
      secrets
    ];
  };
}
