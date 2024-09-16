{
  config,
  pkgs,
  lib,
  neovim-nightly-overlay,
  fenix,
  home-manager,
  ...
}@inputs:

let
  user = "zazed";
  xdg_home = "/home/${user}";
  sharedFiles = import ../shared/files.nix { inherit xdg_home; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  users.users.${user} = {
    name = "${user}";
    home = "/home/${user}";
    group = "users";
    extraGroups = [
      "wheel"
      "video"
    ];
    shell = pkgs.zsh;
    isNormalUser = true;
  };

  programs.zsh.enable = true;

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };

  environment.variables = {
    MOZ_ENABLE_WAYLAND = 1;
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
          ];

          pointerCursor = {
            gtk.enable = true;
            package = pkgs.phinger-cursors;
            name = "phinger-cursors-dark";
            size = 24;
          };

          stateVersion = "24.05";
        };
        programs =
          {
            bemenu.enable = true;
            nnn.enable = true;
            waybar.enable = true;

            opam = {
              enable = true;
              enableZshIntegration = true;
            };

            tmux = import ./tmux.nix { inherit pkgs; };
          }
          // import ../shared/home-manager.nix {
            inherit
              config
              pkgs
              lib
              neovim-nightly-overlay
              ;
          };

        xdg.configFile.nvim = {
          source = ../../configs/nvim;
          recursive = true;
        };

        wayland.windowManager.sway =
          let
            opt = "Mod1";
            cmd = "Mod4";
          in
          {
            enable = true;
            wrapperFeatures.gtk = true;
            checkConfig = false; # to get around the false reporting that the bg doesnt exist
            extraConfig = ''
              bindgesture swipe:right workspace prev
              bindgesture swipe:left workspace next

              seat seat0 xcursor_theme phinger-cursors-dark 24
            '';
            config = {
              modifier = opt;
              terminal = "alacritty";
              defaultWorkspace = "workspace number 1";
              keybindings = lib.mkOptionDefault {
                "${opt}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
                "${opt}+Shift+q" = "kill";
                "${opt}+d" = "exec ${pkgs.bemenu}/bin/bemenu-run";
                "${opt}+Shift+s" = "exec '${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -d)\" - | ${pkgs.wl-clipboard}/bin/wl-copy'";

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
                };
              };
              bars = [
                {
                  position = "top";
                  command = "waybar";
                }
              ];
              gaps = {
                inner = 5;
              };
              window = {
                titlebar = false;
                hideEdgeBorders = "both";
              };
              output = {
                eDP-1 = {
                  scale = "1";
                  bg = "/home/${user}/Documents/walls/hasui.jpg fill";
                };
              };
            };
          };
      };
  };
}
