{ inputs, ... }:
# testing this for now
{
  flake.modules.homeManager.casks =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs.brewCasks; [
        # fixing mac jank
        mos # mouse linear scroll
        aldente # battery limiter
        boring-notch
        # aerospace # i3-like wm
        # swipeaerospace
        sol # dmenu-like app launcher

        # others
        whatsapp
        firefox

        # entertainment
        prismlauncher
      ];
    };
}
