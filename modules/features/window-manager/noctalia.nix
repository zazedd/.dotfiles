{ config, ... }:
{
  flake.wrappers.noctalia =
    { lib, wlib, ... }:
    {
      imports = [ wlib.wrapperModules.noctalia ];

      constructFiles.settings = lib.mkForce {
        relPath = "noctalia/settings.toml";
        content = ''
          [bar.default]
          position = "top"
          background_opacity = 0.93
          capsule = true
          start = ["workspaces", "active-window"]
          center = ["clock"]
          end = [
            "media", "cpu", "temp", "ram", "tray", "notifications",
            "battery", "volume", "brightness", "control-center",
          ]

          [widget.clock]
          format = "{:%H:%M %a, %b %d}"

          [widget.cpu]
          type = "sysmon"
          stat = "cpu_usage"

          [widget.temp]
          type = "sysmon"
          stat = "cpu_temp"

          [widget.ram]
          type = "sysmon"
          stat = "ram_used"

          [widget.volume]
          peek = true

          [widget.brightness]
          peek = true

          [shell]
          font_family = "Iosevka NF"

          [location]
          address = "Tokyo"

          [theme]
          mode = "dark"
          source = "wallpaper"
          wallpaper_scheme = "m3-tonal-spot"

          [wallpaper]
          default.path = "${config.flake.meta.wallpaper}"
          directory = "${../../../configs/wallpaper}"
          fill_mode = "crop"
          transition_on_startup = true
        '';
      };
    };
}
