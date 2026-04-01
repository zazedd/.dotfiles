{ inputs, ... }:
{
  flake.modules.nixos.lenovo = {
    imports = with inputs.self.modules.nixos; [
      system-desktop
      gaming
      # gpu-passthrough
      topology
    ];

    # virtualisation.gpuPassthrough = {
    #   enable = true;
    #   cpus = 8;
    #   vfioId = "10de:24dd,10de:228b";
    #   vmRamMib = 22528;
    # };
  };
}
