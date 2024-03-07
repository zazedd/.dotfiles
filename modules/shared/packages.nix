{ pkgs }:

with pkgs; [
  neovim-nightly

  # General packages for development and system management
  starship
  bash-completion
  bat
  btop
  coreutils
  killall
  fastfetch
  openssh
  wget
  zip

  # Encryption and security tools
  age
  age-plugin-yubikey
  openssl
  gnupg
  libfido2
  pinentry

  # Media-related packages
  ffmpeg
  fd
  font-awesome
  hack-font
  meslo-lgs-nf

  # Text and terminal utilities
  htop
  eza
  jq
  ripgrep
  fzf
  tree
  unrar
  unzip
]
