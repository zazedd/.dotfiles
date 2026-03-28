{
  flake.modules.nixos.server = {
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

    hardware = {
      graphics.enable = true;
      cpu.amd.updateMicrocode = true;
      amdgpu = {
        initrd.enable = true;
        opencl.enable = true;
      };
    };

    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
