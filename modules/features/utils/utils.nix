{ inputs, ... }:
{
  flake.modules.homeManager.desktop-util =
    { pkgs, lib, ... }:
    {
      home.packages =
        with pkgs;
        [
          # shared
          mpv
        ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [
          # fixing mac jank
          mos # mouse linear scroll
          aldente # battery limiter
          # brewCasks.whatsapp
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          whatsapp-electron
          zathura
        ];
    };
}
