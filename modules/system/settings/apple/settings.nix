{ inputs, config, ... }:
let
  user = config.flake.meta.users.zazed.name;
in
{
  flake.modules.darwin.settings = {
    imports = [ inputs.nix-plist-manager.darwinModules.default ];

    home-manager.sharedModules = [ inputs.nix-plist-manager.homeManagerModules.default ];
    home-manager.users.${user}.programs.nix-plist-manager = {
      enable = true;
      options = import ./_definitions/mac.nix;
    };

    system = {
      primaryUser = user;
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
    };
  };
}
