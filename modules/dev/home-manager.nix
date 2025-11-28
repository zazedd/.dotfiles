{
  config,
  pkgs,
  neovim-nightly-overlay,
  external_monitor ? false,
  gpgid ? null,
  nvidia ? false,
  wallpaper ? null,
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
      "davfs2"
      "vboxusers"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    isNormalUser = true;
  };

  security.pam.services."swaylock" = { };

  stylix = {
    enable = true;
    image = wallpaper;
    imageScalingMode = "fill";
    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-dark";
      size = 24;
    };
    fonts = {
      sizes.desktop = 13;
      serif = {
        package = pkgs.nerd-fonts.noto;
        name = "Noto Sans Nerd Font";
      };
      sansSerif = config.stylix.fonts.serif;

      monospace = {
        package = pkgs.nerd-fonts.iosevka;
        name = "Iosevka Nerd Font";
      };
    };

    icons = {
      enable = true;
      dark = "gruvbox-dark-icons-gtk";
      package = pkgs.gruvbox-dark-icons-gtk;
    };
    polarity = "dark";

    override = {
      base00 = "181818";
      base00-hex = "181818";
    };
  };

  programs.zsh.enable = true;
  programs.thunar.enable = true;

  programs.dconf.enable = true;

  # programs.neovim = {
  #   enable = true;
  #   package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  # };

  # setup sops
  sops.age.keyFile = "${xdg_home}/.config/sops/age/keys.txt";

  # Enable home-manager
  home-manager = {
    sharedModules = [
      inputs.sops-nix.homeManagerModule
      {
        stylix.targets = {
          sway.enable = false;
        };
      }
    ];
    useGlobalPkgs = true;
    users.${user} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        sops.age.keyFile = "${xdg_home}/.config/sops/age/keys.txt";
        sops.secrets."copyparty-${user}" = {
          sopsFile = ../../secrets/server.yaml;
        };

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

          stateVersion = "25.05";
        };
        programs = {
          bemenu.enable = true;

          nnn.enable = true;
          opam = {
            enable = true;
            enableZshIntegration = true;
          };

          waybar = import ./waybar.nix { inherit external_monitor; };
          tmux = import ./tmux.nix { inherit pkgs; };
          # qutebrowser = import ./qute.nix { inherit pkgs; };
          mpv.enable = true;

          neovim = {
            enable = true;
            package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
            withPython3 = true;
            plugins = [
              pkgs.vimPlugins.nvim-treesitter.withAllGrammars
            ];
          };

          rclone =
            let
              cfg = {
                user = user;
                type = "webdav";
                hard_delete = true;
                url = "https://cloud.leoms.dev/";
                vendor = "owncloud";
                pacer_min_sleep = "0.01ms";
              };
            in
            {
              enable = true;
              remotes = {
                "private" = {
                  mounts."private" = {
                    enable = true;
                    mountPoint = "${xdg_home}/cloud/private";
                  };
                  config = cfg;
                  secrets = {
                    pass = config.sops.secrets."copyparty-${user}".path;
                  };
                };

                "public" = {
                  mounts."public" = {
                    enable = true;
                    mountPoint = "${xdg_home}/cloud/public";
                  };
                  config = cfg;
                };
              };
            };

          swaylock.enable = true;
        }
        // import ../shared/home-manager.nix {
          inherit
            config
            pkgs
            lib
            neovim-nightly-overlay
            gpgid
            nvidia
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
            wallpaper
            ;
        };
      };
  };
}
