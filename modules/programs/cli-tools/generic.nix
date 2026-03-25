let
  genericPackages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # text and terminal utilities
        htop
        eza
        jq
        ripgrep
        fzf
        tree
        unrar
        unzip
        usbutils
        zoxide
        bash-completion
        bat
        btop
        coreutils
        killall
        fastfetch
        wget
        zip
        gcc
        gnumake
        pkg-config
        gnused
        gnugrep
        gawk
        dua
        magic-wormhole-rs

        # encryption and security tools
        openssl
        gnupg
        pinentry-curses

        # media-related packages
        ffmpeg
        fd
      ];
    };
in
{
  flake.modules.nixos.cli-tools.imports = [ genericPackages ];
  flake.modules.darwin.cli-tools.imports = [ genericPackages ];
}
