{ config, inputs, pkgs, agenix, ... }:

let user = "zazed";
    keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p" ]; in
{
  imports = [
    ../../modules/vm/secrets.nix
    # ../../modules/vm/disk-config.nix
    ../../modules/shared
    ../../modules/shared/cachix
    agenix.nixosModules.default
  ];

  # Use the systemd-boot EFI boot loader.

  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub.device = "/dev/vda";

    networking.hostName = "nixvm"; 
    networking.networkmanager.enable = true;  

    time.timeZone = "Portugal";

    # It's me, it's you, it's everyone
    users.users = {
      ${user} = {
        isNormalUser = true;
        extraGroups = [
          "wheel" 
        ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = keys;
        home = "/home/${user}";
      };

      root = {
        openssh.authorizedKeys.keys = keys;
      };
    };

    # Turn on flag for proprietary software
    nix = {
      # nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
      settings.allowed-users = [ "${user}" ];
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
        '';
    };

    # Manages keys and such
    programs = {
      gnupg.agent.enable = true;
      zsh.enable = true;
    };


    services = {
      xserver = {
        enable = true;

        # LightDM Display Manager
        displayManager.defaultSession = "none+bspwm";
        displayManager.lightdm = {
          enable = true;
          greeters.slick.enable = true;
        };

        # Tiling window manager
        windowManager.bspwm = {
          enable = true;
        };

        # Turn Caps Lock into Ctrl
        layout = "us";
        xkbOptions = "ctrl:nocaps";

        # Better support for general peripherals
        libinput.enable = true;
      };

      qemuGuest.enable = true;
      spice-vdagentd.enable = true;

      # Let's be able to SSH into this machine
      openssh.enable = true;
    };

    # Don't require password for users in `wheel` group for these commands
    # security.sudo = {
    #   enable = true;
    #   extraRules = [{
    #     commands = [
    #      {
    #        command = "${pkgs.systemd}/bin/reboot";
    #        options = [ "NOPASSWD" ];
    #       }
    #     ];
    #     groups = [ "wheel" ];
    #   }];
    # };

    # fonts.packages = with pkgs; [
    #   dejavu_fonts
    #   emacs-all-the-icons-fonts
    #   feather-font # from overlay
    #   jetbrains-mono
    #   font-awesome
    #   noto-fonts
    #   noto-fonts-emoji
    # ];

    environment.systemPackages = with pkgs; [
      agenix.packages."${pkgs.system}".default # "x86_64-linux"
        gitAndTools.gitFull
        inetutils
    ];
  };

  system.stateVersion = "21.05"; # Don't change this
}
