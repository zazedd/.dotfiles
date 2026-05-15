{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.gamemode.enable = true; # for performance mode

      programs.steam = {
        enable = true;
      };

      environment.systemPackages = with pkgs; [
        heroic
      ];

      environment.variables = {
        __GLX_VENDOR_LIBRARY_NAME = "mesa";
        GALLIUM_DRIVER = "zink";
        MESA_LOADER_DRIVER_OVERRIDE = "zink";
      };
    };
}
