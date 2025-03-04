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
    ../../modules/asahi/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
    ./hardware-configuration.nix
    ./apple-silicon-support/default.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.m1n1CustomLogo = ./sillycat.png;

  networking = {
    hostName = "shitbook"; # Define your hostname.
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };

    networkmanager.enable = true;
    networkmanager.wifi.backend = "iwd";

    nameservers = [ "9.9.9.9" ];
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Portugal";

  hardware = {
    asahi = {
      peripheralFirmwareDirectory = ./firmware;
      useExperimentalGPUDriver = true;
      experimentalGPUInstallMode = "overlay";
    };
    graphics = {
      enable = true;
    };
  };

  # Brighness control
  programs.light.enable = true;
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  # Swap fn and ctrl
  systemd.services.fnctrl = {
    script = ''
      echo 1 | tee /sys/module/hid_apple/parameters/swap_fn_leftctrl
    '';
    wantedBy = [ "multi-user.target" ];
  };

  # Start battery threshold at 80%
  systemd.services.thresh = {
    script = ''
      echo 80 | tee /sys/class/power_supply/macsmc-battery/charge_control_end_threshold
    '';
    wantedBy = [ "multi-user.target" ];
  };

  services.xserver.enable = false;

  services.dbus.enable = true;

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

  # Power management shit
  powerManagement.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      TLP_ENABLE = 1;

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "balanced";

      CPU_MAX_PERF_ON_AC = 100;
      CPU_MAX_PERF_ON_BAT = 80;
    };
  };

  # SSH
  # services.openssh.enable = true;

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

  services.tailscale.enable = true;
  programs.extra-container.enable = true;

  fonts = {
    fontDir.enable = true;
    packages = with pkgs.nerd-fonts; [
      iosevka
    ];
  };

  system.stateVersion = "25.05";
}
