{
  config,
  pkgs,
  neovim-nightly-overlay,
  external_monitor,
  gpgid ? null,
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
    home = "${xdg_home}";
    group = "users";
    extraGroups = [
      "wheel"
      "video"
      "vboxusers"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    isNormalUser = true;
  };

  programs.zsh.enable = true;

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
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

          sessionVariables = {
            MOZ_ENABLE_WAYLAND = 1;
            XDG_CURRENT_DESKTOP = "sway";
            # XDG_CONFIG_HOME = "${xdg_home}/.dotfiles/configs";
          };

          pointerCursor = {
            gtk.enable = true;
            package = pkgs.phinger-cursors;
            name = "phinger-cursors-dark";
            size = 24;
          };

          stateVersion = "25.05";
        };
        programs =
          {
            bemenu = {
              enable = true;
              # settings = {
              #   "ignore-case" = true;
              #   "center" = true;
              #   "counter" = "always";
              #   "line-height" = 25;
              #   "list" = 10;
              #   "fixed-height" = true;
              #   "width-factor" = 0.3;
              #   "border" = 1;
              #   "fn" = "Iosevka Nerd Font 15";
              #   fb = "#181818";
              #   ff = "#ebdbb2";
              #   nb = "#181818";
              #   nf = "#ebdbb2";
              #   tb = "#181818";
              #   hb = "#181818";
              #   tf = "#fb4934";
              #   hf = "#fabd2f";
              #   af = "#ebdbb2";
              #   ab = "#181818";
              #   bdr = "#ebdbb2";
              # };
            };

            nnn.enable = true;
            waybar.enable = true;

            opam = {
              enable = true;
              enableZshIntegration = true;
            };

            tmux = import ./tmux.nix { inherit pkgs; };
            qutebrowser = import ./qute.nix { inherit pkgs; };
          }
          // import ../shared/home-manager.nix {
            inherit
              config
              pkgs
              lib
              neovim-nightly-overlay
              gpgid
              ;
          };

        services.gpg-agent = {
          enable = true;
          pinentry = {
            package = pkgs.pinentry;
            program = "pinentry-curses";
          };
        };

        xdg.configFile.nvim = {
          source = ../../configs/nvim;
          recursive = true;
        };

        wayland.windowManager.sway = import ./sway.nix {
          inherit
            pkgs
            user
            lib
            external_monitor
            ;
        };
      };
  };
}
