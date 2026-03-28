{ inputs, ... }:
{
  flake.modules.homeManager.desktop-util =
    { pkgs, lib, ... }:
    {
      home.packages =
        with pkgs;
        [
          # shared
          zathura
          mpv
        ]
        ++ lib.optionals stdenv.isDarwin [
          # fixing mac jank
          mos # mouse linear scroll
          aldente # battery limiter
          # brewCasks.whatsapp
        ]
        ++ lib.optionals stdenv.isLinux [
          whatsapp-electron
        ];
    };
}
