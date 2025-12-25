{
  config,
  pkgs,
  lib,
  neovim-nightly-overlay,
  fenix,
  home-manager,
  old-betterdisplay-pkgs,
  ...
}@inputs:

let
  user = "zazed";
  xdg_home = "/Users/${user}";
  sharedFiles = import ../shared/files.nix { inherit xdg_home; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  users.users.${user} = {
    name = "${user}";
    home = "${xdg_home}";
    isHidden = false;
    shell = pkgs.zsh;
    uid = 501;
  };

  imports = [ ./tailscale.nix ];

  sops.age.keyFile = "${xdg_home}/.config/sops/age/keys.txt";

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };
    taps = builtins.attrNames config.nix-homebrew.taps;

    brews = [ ];
  };

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
          packages = pkgs.callPackage ./packages.nix { inherit pkgs old-betterdisplay-pkgs; };
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
          ];

          sessionVariables = {
            XDG_CONFIG_HOME = "${xdg_home}/.dotfiles/configs";
          };

          stateVersion = "25.11";
        };
        programs = { 
          tmux = import ../dev/tmux.nix { inherit pkgs; };

          neovim = {
            enable = true;
            package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
            withPython3 = true;
          };
        } // import ../shared/home-manager.nix {
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
}
