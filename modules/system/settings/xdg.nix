{
  flake.modules.nixos.xdg =
    { pkgs, ... }:
    {
      xdg = {
        portal = {
          enable = true;
          xdgOpenUsePortal = true;
          config = {
            common = {
              default = "wlr";
            };
          };
          wlr.enable = true;
          wlr.settings.screencast = {
            output_name = "HDMI-A-1";
            chooser_type = "simple";
            chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
          };
          extraPortals = with pkgs; [
            xdg-desktop-portal-wlr
            xdg-desktop-portal-gtk
            xdg-desktop-portal-hyprland
          ];
        };
      };
    };
}
