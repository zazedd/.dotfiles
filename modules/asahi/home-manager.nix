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
            XDG_CONFIG_HOME = "${xdg_home}/.dotfiles/configs";
          };

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

        wayland.windowManager.sway = import ./sway.nix { inherit pkgs user lib; };
      };
  };
}
