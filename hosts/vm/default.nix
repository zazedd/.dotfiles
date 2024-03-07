{ config, pkgs, agenix, modulesPath, ... }@inputs:

let user = "zazed";
keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p" ]; in
{
  system.stateVersion = "22.05";

# Configure networking
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

# Create user "test"
  services.getty.autologinUser = user;
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

# Enable paswordless ‘sudo’ for the "test" user
  security.sudo.wheelNeedsPassword = false;

# Make it output to the terminal instead of separate window
  virtualisation.graphics = false;
}
# {
#   imports = [
#     ../../modules/vm/secrets.nix
#     # ../../modules/vm/disk-config.nix
#     ../../modules/shared
#     ../../modules/shared/cachix
#     # ./hardware.nix
#     agenix.nixosModules.default
#     "${modulesPath}/virtualisation/qemu-vm.nix"
#   ];
#
#   # Use the systemd-boot EFI boot loader.
#   # boot.loader.systemd-boot.enable = true;
#   # boot.loader.efi.canTouchEfiVariables = true;
#   # boot.loader.grub.device = "/dev/vda";
#
#   networking.hostName = "nixvm"; 
#   # networking.networkmanager.enable = true;  
#
#   time.timeZone = "Portugal";
#
#   virtualisation.graphics = false;
#
#   nixpkgs = {
#     overlays =  [
#       inputs.neovim-nightly-overlay.overlay
#     ];
#   };
#
#   users.users = {
#     ${user} = {
#       isNormalUser = true;
#       extraGroups = [
#         "wheel" 
#       ];
#       shell = pkgs.zsh;
#       openssh.authorizedKeys.keys = keys;
#       home = "/home/${user}";
#     };
#
#     root = {
#       openssh.authorizedKeys.keys = keys;
#     };
#   };
#
#   nix = {
#     # nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
#     settings.allowed-users = [ "${user}" ];
#     package = pkgs.nixUnstable;
#     extraOptions = ''
#       experimental-features = nix-command flakes
#       '';
#   };
#
#   programs = {
#     gnupg.agent.enable = true;
#     zsh.enable = true;
#   };
#
#   services = {
#     xserver = {
#       enable = true;
#
#       # displayManager.defaultSession = "none+dwm";
#       # displayManager.lightdm = {
#       #   enable = true;
#       #   greeters.slick.enable = true;
#       # };
#       #
#       # windowManager.dwm. enable = true;
#
#       xkb.layout = "us";
#       xkb.options = "ctrl:nocaps";
#
#       libinput.enable = true;
#     };
#
#     # qemuGuest.enable = true;
#     # spice-vdagentd.enable = true;
#
#     openssh.enable = true;
#   };
#
#   environment.systemPackages = with pkgs; [
#     agenix.packages."${pkgs.system}".default # "x86_64-linux"
#       gitAndTools.gitFull
#       inetutils
#   ];
#
#   system.stateVersion = "21.05"; # Don't change this
# }
