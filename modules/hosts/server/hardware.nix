{ inputs, lib, ... }:
{
  flake.modules.nixos.server =
    { config, ... }:
    {
      imports = [
        inputs.nixos-hardware.nixosModules.lenovo-legion-16ach6h-nvidia
      ];

      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = false;

        initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "ehci_pci"
          "nvme"
          "usb_storage"
          "usbhid"
          "sd_mod"
        ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-amd" ];
        extraModulePackages = [ ];
      };

      services.xserver.enable = true;

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
