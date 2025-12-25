{
  config,
  pkgs,
  lib,
  neovim-nightly-overlay,
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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA47RV+m4PubAmG21MCU7KCyWEvrFS+HGfFloX16gUjx"
    ];
    extraGroups = [
      "wheel"
      "video"
      "media"
      "cloud"
    ];
    shell = pkgs.zsh;
    isNormalUser = true;
  };

  imports = [ ../dev/tailscale.nix ];

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

          stateVersion = "24.05";
        };
        programs =
          {
            tmux.enable = true;
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
      };
  };
}
