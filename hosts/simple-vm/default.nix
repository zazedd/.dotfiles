{ config, pkgs, agenix, modulesPath, ... }@inputs:

let user = "zazed";
in
{
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  nixpkgs = {
    overlays =  [
      inputs.neovim-nightly-overlay.overlay
    ];
  };

  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true;
  };

  services = {
    getty.autologinUser = user;
    openssh.enable = true;
  };

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = false;

  services.cron = {
    enable = true;
    systemCronJobs = [
      ''* * * * * zazed echo "Hello World $(date)" >> ~/hello.txt''
    ];
  };

  environment.systemPackages = with pkgs; [
    neofetch
    neovim-nightly
    openssl
  ];

  system.stateVersion = "23.11";
}
