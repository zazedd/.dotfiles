{
  flake.modules.nixos.server = {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "ehci_pci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = true;
  };
}
