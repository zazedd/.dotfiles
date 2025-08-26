{
  pkgs,
  lib,
  user,
  external_monitor,
  wallpaper,
  ...
}:
let
  opt = "Mod1";
  cmd = "Mod4";
  bemenu_opts = "-i -c --counter always -H 2 -l 10 --fixed-height -W 0.3 -B 1 --fn 'Iosevka Nerd Font 15' --fb \"#181818\" --ff \"#ebdbb2\" --nb \"#181818\" --nf \"#ebdbb2\" --tb \"#181818\" --hb \"#181818\" --tf \"#fb4934\" --hf \"#fabd2f\" --nf \"#ebdbb2\" --af \"#ebdbb2\" --ab \"#181818\" --bdr \"#ebdbb2\"";
in
{
  enable = true;
  wrapperFeatures.gtk = true;
  checkConfig = false; # to get around the false reporting that the bg doesnt exist
  extraConfig = ''
    bindgesture swipe:right workspace prev
    bindgesture swipe:left workspace next
    bindsym XF86PowerOff exec suspend

    seat seat0 xcursor_theme phinger-cursors-dark 24
  '';
  config = {
    modifier = opt;
    terminal = "alacritty";
    defaultWorkspace = "workspace number 1";
    keybindings = lib.mkOptionDefault {
      "${opt}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
      "${opt}+Shift+q" = "kill";
      "${opt}+d" = "exec ${pkgs.bemenu}/bin/bemenu-run ${bemenu_opts}";
      "${opt}+Shift+s" =
        "exec '${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -d)\" - | ${pkgs.wl-clipboard}/bin/wl-copy'";
      "${opt}+space" = "floating toggle";
      "${cmd}+0" = "input type:keyboard xkb_switch_layout next";

      # mac style copying
      "${cmd}+x" = "exec ${pkgs.wtype}/bin/wtype -P XF86Cut";
      "${cmd}+c" = "exec ${pkgs.wtype}/bin/wtype -P XF86Copy";
      "${cmd}+v" = "exec ${pkgs.wtype}/bin/wtype -P XF86Paste";

    };
    fonts = {
      names = [ "Iosevka" ];
      style = "Regular";
      size = 13.0;
    };
    input = {
      "type:touchpad" = {
        dwt = "enabled";
        tap = "enabled";
        natural_scroll = "enabled";
        middle_emulation = "enabled";
        accel_profile = "flat";
        pointer_accel = "0.7";
        scroll_factor = "0.25";
      };
      "type:keyboard" = {
        repeat_delay = "350";
        xkb_layout = "us,pt";
      };
    };
    bars = [
      {
        position = "top";
        command = "${pkgs.waybar}/bin/waybar";
        mode = "hide";
      }
    ];
    gaps = {
      inner = 5;
    };
    window = {
      titlebar = false;
      hideEdgeBorders = "both";
    };
    output =
      if external_monitor then
        {
          eDP-1 = {
            disable = "";
          };
          HDMI-A-1 = {
            scale = "1.25";
            bg = "${wallpaper} fill";
            resolution = "3840x2160@119.880Hz";
          };
        }
      else
        {
          eDP-1 = {
            scale = "1";
            bg = "${wallpaper} fill";
          };
        };
  };
}
