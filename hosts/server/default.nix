{
  agenix,
  config,
  pkgs,
  ...
}@inputs:

let
  user = "zazed";
in

{

  imports = [
    # agenix.darwinModules.default
    # ../../modules/asahi/secrets.nix
    ../../modules/server/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "xinho"; # Define your hostname.
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  time.timeZone = "Portugal";

  services.dbus.enable = true;

  services.openssh.enable = true;

  nixpkgs.overlays = [ (import ./apple-silicon-support/packages/overlay.nix) ];

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
  environment.systemPackages =
    with pkgs;
    [
      agenix.packages."${pkgs.system}".default
    ]
    ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  system.stateVersion = "24.11";
}
