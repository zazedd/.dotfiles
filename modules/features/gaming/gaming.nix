{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.gamemode.enable = true;

      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
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

  flake.modules.darwin.gaming =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        brewCasks.moonlight
        (brewCasks.steam.overrideAttrs (_: {
          src = pkgs.fetchurl {
            url = "https://cdn.cloudflare.steamstatic.com/client/installer/steam.dmg";
            sha256 = "sha256-4av7qqe+Pg9IoODUwxMjPgWGGx0mrzKDDdyDi+iPJpE=";
          };
        }))
      ];
    };
}
