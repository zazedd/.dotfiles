{ config, pkgs, lib, ... }:

let
  user = "zazed";
  xdg_home  = "/home/${user}";
  shared-programs = import ../shared/home-manager.nix { inherit config pkgs lib; };
  shared-files = import ../shared/files.nix { inherit xdg_home; };
in
{

  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    file = shared-files // import ./files.nix { inherit user; };
    stateVersion = "21.05";
  };

  # Screen lock
  # services = {
  #   screen-locker = {
  #     enable = true;
  #     inactiveInterval = 10;
  #     lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 15";
  #   };
  # };

  programs = shared-programs // { gpg.enable = true; };
}
