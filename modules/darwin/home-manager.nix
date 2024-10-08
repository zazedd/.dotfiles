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
  xdg_home = "/Users/${user}";
  sharedFiles = import ../shared/files.nix { inherit xdg_home; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
    ./dock
  ];

  users.users.${user} = {
    name = "${user}";
    home = "${xdg_home}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };
    taps = builtins.attrNames config.nix-homebrew.taps;

    brews = [
      "gmp"
      "opam"
    ];

    # mas = mac app store
    # https://github.com/mas-cli/mas
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # masApps = {
    #   "1password" = 1333542190;
    #   "wireguard" = 1451685025;
    # };
  };

  nixpkgs = {
    overlays = [
      (
        _: super:
        let
          pkgs = fenix.inputs.nixpkgs.legacyPackages.${super.system};
        in
        fenix.overlays.default pkgs pkgs
      )
      inputs.neovim-nightly-overlay.overlay
    ];
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
            XDG_CONFIG_HOME = "${xdg_home}/.dotfiles/configs";
          };

          stateVersion = "24.05";
        };
        programs =
          { }
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

        # Marked broken Oct 20, 2022 check later to remove this
        # https://github.com/nix-community/home-manager/issues/3344
        manual.manpages.enable = false;
      };
  };

  # Fully declarative dock using the latest from Nix Store
  local = {
    dock = {
      enable = true;
      entries = [
        {
          path = "${config.users.users.${user}.home}/Downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };
}
