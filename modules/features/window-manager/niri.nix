{
  self,
  inputs,
  lib,
  config,
  ...
}:
{
  flake.meta.wallpaper = ../../../configs/wallpaper/hasui-autumn2.png;

  flake.modules.nixos.windowmanager =
    { pkgs, ... }:
    {
      imports = [ inputs.self.modules.nixos.xdg ];

      config = {
        services.seatd.enable = true;
        programs.niri = {
          enable = true;
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
        };
        environment.systemPackages = with pkgs; [
          pavucontrol
          xwayland-satellite
        ];
      };
    };

  flake.wrappers.fuzzel =
    { pkgs, wlib, ... }:
    {
      imports = [ wlib.wrapperModules.fuzzel ];
      package = pkgs.fuzzel;
      settings = {
        main = {
          font = "Iosevka Mono";
          tabs = 2;
          width = 40;
          use-bold = true;
          placeholder = "Search";
        };
        colors = {
          background = "#ffffffdd";
          text = "#000000ff";
          match = "#54546Dff";
          selection = "#f2f2f2ff";
          selection-match = "#8f0075ff";
          selection-text = "#3548cfff";
          border = "#c4c4c4ff";
        };
      };
    };

  flake.wrappers.niri =
    { pkgs, wlib, ... }:
    let
      wpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [ wlib.wrapperModules.niri ];

      settings = {
        prefer-no-csd = { };
        spawn-at-startup = [ "${lib.getExe wpkgs.noctalia}" ];

        input.keyboard = {
          xkb.layout = "us";
          repeat-delay = 200;
          repeat-rate = 35;
        };

        hotkey-overlay.skip-at-startup = { };

        layout = {
          gaps = 5;
          focus-ring.width = 1.5;
          default-column-width.proportion = 1.0;
        };

        binds = {
          "Mod+Return".spawn = lib.getExe pkgs.alacritty;
          "Mod+D".spawn-sh =
            "cmd=$(${pkgs.dmenu-rs}/bin/dmenu_path | ${lib.getExe wpkgs.fuzzel} --dmenu) && niri msg action spawn -- $cmd";
          "Mod+B".spawn = lib.getExe pkgs.firefox;
          "Mod+Shift+Q".close-window = { };

          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;
          "Mod+4".focus-workspace = 4;
          "Mod+5".focus-workspace = 5;
          "Mod+6".focus-workspace = 6;
          "Mod+7".focus-workspace = 7;
          "Mod+8".focus-workspace = 8;
          "Mod+9".focus-workspace = 9;

          "Mod+Shift+1".move-column-to-workspace = 1;
          "Mod+Shift+2".move-column-to-workspace = 2;
          "Mod+Shift+3".move-column-to-workspace = 3;
          "Mod+Shift+4".move-column-to-workspace = 4;
          "Mod+Shift+5".move-column-to-workspace = 5;
          "Mod+Shift+6".move-column-to-workspace = 6;
          "Mod+Shift+7".move-column-to-workspace = 7;
          "Mod+Shift+8".move-column-to-workspace = 8;
          "Mod+Shift+9".move-column-to-workspace = 9;

          "Mod+H".focus-column-left = { };
          "Mod+J".focus-window-down = { };
          "Mod+K".focus-window-up = { };
          "Mod+L".focus-column-right = { };

          "Mod+Shift+H".move-column-left = { };
          "Mod+Shift+J".move-window-down = { };
          "Mod+Shift+K".move-window-up = { };
          "Mod+Shift+L".move-column-right = { };

          "Mod+equal".set-column-width = "+3%";
          "Mod+minus".set-column-width = "-3%";
          "Mod+F".maximize-column = { };
          "Mod+Shift+F".set-column-width = "50%";
        };

        animations.workspace-switch.off = { };
      };
    };
}
