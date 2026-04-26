{ lib, ... }:
{
  flake.modules.nixos.gpu-passthrough =
    { config, ... }:
    {
      options.virtualisation.gpuPassthrough = {
        enable = lib.mkEnableOption "GPU passthrough";
        cpus = lib.mkOption { type = lib.types.int; };
        vfioId = lib.mkOption { type = lib.types.str; };
        vmRamMib = lib.mkOption { type = lib.types.int; };
        inVfioMode = lib.mkOption {
          type = lib.types.bool;
          default = false;
          internal = true;
        };
      };

      config = lib.mkIf config.virtualisation.gpuPassthrough.enable (
        let
          cfg = config.virtualisation.gpuPassthrough;
        in
        {
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
                cpus = cfg.cpus - 1;
                hugepages = cfg.vmRamMib / 2;
              in
              {
                virtualisation.gpuPassthrough.inVfioMode = true;

                powerManagement.cpuFreqGovernor = "performance";

                boot.kernelParams = [
                  "hugepages=${toString hugepages}"

                  # cpu pinning
                  "isolcpus=1-${toString cpus}"
                  "nohz_full=1-${toString cpus}"
                  "rcu_nocbs=1-${toString cpus}"

                  "amd_iommu=on"
                  "iommu=pt"
                  "pcie_aspm=off"

                  "vfio-pci.ids=${cfg.vfioId}"

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
        }
      );
    };

  # flake.modules.homeManager.gpu-passthrough =
  #   { osConfig, lib, ... }:
  #   {
  #     config =
  #       lib.mkIf
  #         (osConfig.virtualisation.gpuPassthrough.enable && osConfig.virtualisation.gpuPassthrough.inVfioMode)
  #         {
  #           wayland.windowManager.sway.config.output = {
  #             "eDP-1" = {
  #               disable = "";
  #             };
  #           };
  #         };
  #   };
}
