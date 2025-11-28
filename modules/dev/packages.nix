{ pkgs }:

with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [
  # general
  firefox
  zathura
  tigervnc
  deluge
  mpv
  usbutils
  pinentry
  wireguard-tools
  kdePackages.dolphin
  kdePackages.plasma-desktop
  rclone

  # programming
  alacritty
  bubblewrap
  libev
  libevent
  claude-code

  ## nix
  nixfmt-rfc-style
  nil
  nixd

  # wayland stuff
  wl-clipboard
  wtype

  ## screenshot
  grim
  slurp
  swappy

  ## gaming
  prismlauncher
  moonlight-qt

  ## entertainment

  ## others
  libsForQt5.qt5.qtwayland
]
