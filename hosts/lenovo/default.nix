{
  config,
  pkgs,
  lib,
  ...
}@inputs:

let
  user = "zazed";
in

{
  imports = [
    ../../profiles/dev/home-manager.nix
    ../../profiles/shared
    ../../profiles/shared/cachix

    ../../profiles/gaming

    ../../profiles/shared/default.nix
    ./hardware-configuration.nix
  ];

  boot.loader = {
    # systemd-boot.enable = false;
    grub = {
      enable = false;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
    systemd-boot = {
      enable = lib.mkForce false;
      edk2-uefi-shell.enable = true;
      edk2-uefi-shell.sortKey = "z_edk2";
    };
    efi.canTouchEfiVariables = true;

  };

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.supportedFilesystems = [ "ntfs" ];

  programs.nix-ld.enable = true;

  networking = {
    hostName = "shitmachine";
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };

    wireguard.enable = true;

    networkmanager.enable = true;
    networkmanager.wifi.backend = "iwd";

    nameservers = [ "9.9.9.9" ];
  };

  time.timeZone = "Portugal";

  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    dynamicBoost.enable = false;
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = false;

    package = config.boot.kernelPackages.nvidiaPackages.latest;
    # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #   version = "570.181";
    #   sha256_64bit = "sha256-8G0lzj8YAupQetpLXcRrPCyLOFA9tvaPPvAWurjj3Pk=";
    #   sha256_aarch64 = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
    #   openSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
    #   settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
    #   persistencedSha256 = lib.fakeSha256;
    # };
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

  security.rtkit.enable = true;
  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        common = {
          default = "wlr";
        };
      };
      wlr.enable = true;
      wlr.settings.screencast = {
        output_name = "HDMI-A-1";
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
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
  environment.systemPackages = [
    pkgs.sbctl
  ]
  ++ (import ../../profiles/shared/packages.nix { inherit pkgs; })
  ++ (import ../../profiles/gaming/packages.nix { inherit pkgs; });

  fonts = {
    fontDir.enable = true;
    packages = with pkgs.nerd-fonts; [
      iosevka
    ];
  };

  ## gpu passthru

  virtualisation.libvirtd = {
    enable = true;
    qemu.runAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };
  programs.virt-manager.enable = true;
  specialisation = {
    vfio.configuration =
      let
        vmRamMib = 22528;
        hugepages = vmRamMib / 2;
      in
      {
        powerManagement.cpuFreqGovernor = "performance";
        home-manager.users.${user}.wayland.windowManager.sway.config.output = {
          "eDP-1" = {
            enable = "";
          };
        };

        boot.kernelParams = [
          "hugepages=${toString hugepages}"

          # cpu pinning
          "isolcpus=1-7"
          "nohz_full=1-7"
          "rcu_nocbs=1-7"

          "amd_iommu=on"
          "iommu=pt"
          "pcie_aspm=off"

          "vfio-pci.ids=10de:24dd,10de:228b"

          "video=efifb:off"
          "video=vesafb:off"

          "modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm,nouveau,nvidiafb"
        ];

        boot.kernel.sysctl."vm.nr_hugepages" = hugepages;

        boot.kernelModules = [ "kvm-amd" ];

        boot.initrd.kernelModules = [
          "vfio"
          "vfio_pci"
          "vfio_iommu_type1"
        ];

        boot.initrd.availableKernelModules = [ "vfio-pci" ];

        boot.blacklistedKernelModules = [
          "nvidia"
          "nvidia_drm"
          "nvidia_modeset"
          "nvidia_uvm"
          "nouveau"
          "nvidiafb"
        ];
      };
  };

  system.stateVersion = "25.05";
}
