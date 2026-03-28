{ inputs, ... }:
{
  flake.modules.nixos.lenovo = {
    imports = with inputs.self.modules.nixos; [
      system-desktop
      gaming
      gpu-passthrough
    ];

    virtualisation.gpuPassthrough = {
      enable = true;
      cpus = 8;
      vfioId = "10de:24dd,10de:228b";
      vmRamMib = 22528;
    };

    windowmanager.wallpaper = ../../../configs/wallpaper/hasui-autumn2.png;
  };
}
