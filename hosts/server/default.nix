{
  agenix,
  config,
  pkgs,
  nix-minecraft,
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
    nix-minecraft.nixosModules.minecraft-servers
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

  nixpkgs.overlays = [ nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers = {
      burros = {
        enable = true;
        package = pkgs.purpurServers.purpur-1_21_1;

        serverProperties = {
          gamemode = "survival";
          difficulty = "normal";
          simulation-distance = "12";
          server-port = "42069";
        };
      };
    };
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
