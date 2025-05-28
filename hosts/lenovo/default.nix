{
  config,
  pkgs,
  ...
}@inputs:

let
  user = "zazed";
in

{
  imports = [
    ../../modules/dev/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix

    ../../modules/shared/default.nix
  ];

  networking = {
    hostName = "shitmachine"; # Define your hostname.
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };

    networkmanager.enable = true;
    networkmanager.wifi.backend = "iwd";

    nameservers = [ "9.9.9.9" ];
  };

  time.timeZone = "Portugal";

  hardware = {
    graphics = {
      enable = true;
    };

    opengl = {
      enable = true;
      nvidia = true;
    };
  };

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  services.xserver.enable = false;
  services.dbus.enable = true;
  services.tailscale.enable = true;

  # Sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  xdg = {
    portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };

  # Setup user, packages, programs
  nix = {
    # package = pkgs.nixVersions.git;
    settings.trusted-users = [
      "@admin"
      "${user}"
    ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Load configuration that is shared across systems
  environment.systemPackages = (import ../../modules/shared/packages.nix { inherit pkgs; });

  fonts = {
    fontDir.enable = true;
    packages = with pkgs.nerd-fonts; [
      iosevka
    ];
  };

  system.stateVersion = "25.05";
}
