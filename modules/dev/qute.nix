{ pkgs, ... }:
{
  enable = true;
  settings = {
    colors = {
      hints = {
        bg = "#111111";
        fg = "#ffffff";
      };
      tabs.bar.bg = "#111111";
    };
    tabs.tabs_are_windows = true;
    tabs.position = "left";
    fonts.default_size = 14;
  };
}
