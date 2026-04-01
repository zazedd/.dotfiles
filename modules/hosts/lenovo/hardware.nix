{ inputs, lib, ... }:
{
  flake.modules.nixos.lenovo =
    { config, ... }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      services.pipewire = {
        enable = true;
        pulse.enable = true;
        jack.enable = true;
      };

      services.xserver.videoDrivers = [ "nvidia" ];
      services.dbus.enable = true;

      boot = {
        loader = {
          systemd-boot.enable = lib.mkForce false;
          efi.canTouchEfiVariables = true;
        };

        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };

        supportedFilesystems = [ "ntfs" ];

        initrd.luks.devices."cryptroot".device = "/dev/disk/by-label/NIXENCRYPT";
        initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        initrd.kernelModules = [
          "dm-snapshot"
          "cryptd"
        ];
        kernelModules = [ "kvm-amd" ];
        extraModulePackages = [ ];
      };

      hardware = {
        graphics.enable = true;
        cpu.amd.updateMicrocode = true;

        nvidia = {
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
      };

      nixpkgs.hostPlatform = "x86_64-linux";
    };
}
