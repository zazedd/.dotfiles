{ inputs, ... }:
{
  flake.modules.nixos.server = {
    imports = with inputs.self.modules.nixos; [
      zazed
    ];

    home-manager.users.zazed.imports = with inputs.self.modules.homeManager; [
      system-minimal
      shell
      browser
    ];
  };
}
