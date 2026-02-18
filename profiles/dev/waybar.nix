{
  external_monitor,
  ...
}:
{
  enable = true;
  style = builtins.readFile ../../configs/waybar/style.css;
  settings = {
    main = {
      layer = "top";
      position = "top";
      height = 32;
      spacing = 10;

      "modules-left" = [
        "sway/workspaces"
        "sway/window"
        "sway/mode"
      ];

      "modules-center" = [
        "custom/clock"
      ];

      "modules-right" = [
        "custom/brightness"
        "backlight/slider"
        "custom/audio"
        "pulseaudio/slider"
        "cpu"
        "memory"
        "battery"
      ];

      "sway/mode" = {
        format = "<span style=\"italic\">{}</span>";
      };

      "sway/workspaces" = {
        "all-outputs" = true;
      };

      "sway/window" = {
        format = "{title}";
      };

      "custom/clock" = {
        exec = "echo $(date +'%H:%M | %d/%m/%Y')";
        interval = 15;
      };

      "custom/brightness" = {
        format = "󰃟";
      };

      "backlight/slider" = {
        min = 0;
        max = 100;
        orientation = "horizontal";
        device = if external_monitor then "" else "apple-panel-bl";
      };

      "custom/audio" = {
        format = "|  󰖀";
      };

      "pulseaudio/slider" = {
        min = 0;
        max = 100;
        orientation = "horizontal";
      };

      "cpu" = {
        format = "|     {usage}%";
        tooltip = true;
      };

      "memory" = {
        format = "|     {used}GiB";
        tooltip = true;
      };

      "battery" = {
        format = "|  {icon}  {capacity}% ";
        "format-icons" = {
          default = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          charging = [
            "󰁻󱐋"
            "󰁼󱐋"
            "󰁽󱐋"
            "󰁾󱐋"
            "󰁿󱐋"
            "󰂀󱐋"
            "󰂁󱐋"
            "󰂂󱐋"
            "󰁹󱐋"
          ];
          plugged = [
            "󰁻󱐥"
            "󰁼󱐥"
            "󰁽󱐥"
            "󰁾󱐥"
            "󰁿󱐥"
            "󰂀󱐥"
            "󰂁󱐥"
            "󰂂󱐥"
            "󰁹󱐥"
          ];
          unknown = [
            "󰁻󱐥"
            "󰁼󱐥"
            "󰁽󱐥"
            "󰁾󱐥"
            "󰁿󱐥"
            "󰂀󱐥"
            "󰂁󱐥"
            "󰂂󱐥"
            "󰁹󱐥"
          ];
        };
        interval = 30;
        states = {
          warning = 25;
          critical = 10;
        };
        tooltip = true;
        "on-click" = "2";
      };
    };
  };
}
