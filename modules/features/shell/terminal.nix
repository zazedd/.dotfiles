{
  flake.modules.homeManager.shell = {
    programs.alacritty = {
      enable = true;
      theme = "kanagawa_dragon";
      settings = {
        window = {
          opacity = 1.0;
          decorations = "None";

          padding = {
            x = 10;
            y = 10;
          };
        };

        font = {
          size = 15.0;

          normal.family = "Iosevka Nerd Font";
          bold.family = "Iosevka Nerd Font";
          italic.family = "Iosevka Nerd Font";
          bold_italic.family = "Iosevka Nerd Font";
        };

        keyboard = {
          bindings = [
            {
              key = "Return";
              mods = "Shift";
              chars = "\x1b\r";
            }
          ];
        };
      };
    };
  };
}
