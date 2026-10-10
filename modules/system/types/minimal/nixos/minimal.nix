{ config, ... }:
# default settings needed for all nixosConfigurations
{
  flake.modules.nixos.system-minimal = _: {
    system.stateVersion = "25.11";

    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      substituters = [
        # high priority since it's almost always used
        "https://cache.nixos.org?priority=10"
        "https://cache.leoms.dev/dotfiles"
        # "https://install.determinate.systems"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "dotfiles:L8eOKFwsyzXtQShyNzr9HpLA2T2owJFE9XbzMyb3Rn0="
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM"
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      download-buffer-size = 1024 * 1024 * 1024;

      trusted-users = [
        "root"
        "@wheel"
        config.flake.meta.users.zazed.name
      ];
    };

    nix = {
      optimise.automatic = true;
      extraOptions = ''
        warn-dirty = false
        keep-outputs = true
      '';
    };
  };
}
