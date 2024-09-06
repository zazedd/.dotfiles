{ config, pkgs, lib, neovim-nightly-overlay, fenix, home-manager, ... }@inputs:

let
  user = "zazed";
  xdg_home  = "/home/${user}";
  sharedFiles = import ../shared/files.nix { inherit xdg_home; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  users.users.${user} = {
    name = "${user}";
    home = "/home/${user}";
    group = "users";
    extraGroups = [ "wheel" "video" ];
    shell = pkgs.zsh;
    isNormalUser = true;
  };

  programs.zsh.enable = true;

  nixpkgs = {
    overlays =  [
      inputs.neovim-nightly-overlay.overlay
    ];
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];

        stateVersion = "24.05";
      };
      programs = { } // import ../shared/home-manager.nix { inherit config pkgs lib neovim-nightly-overlay; };

      xdg.configFile.nvim = {
        source = ../../configs/nvim;
        recursive = true;
      };

      xsession.windowManager.i3 = {
        enable = true;
        config = {
          modifier = "Mod4";
          terminal = "alacritty";
          fonts = {
            names = [ "Iosevka" ];
            style = "Bold";
            size = 13.0;
          };
          gaps = {
            top = 5;
            bottom = 5;
            left = 5;
            right = 5;
          };
          window = { 
            hideEdgeBorders = "both";
          };
        };
      };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };
}
