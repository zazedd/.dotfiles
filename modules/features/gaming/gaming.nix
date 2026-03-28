{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.gamemode.enable = true; # for performance mode

      programs.steam = {
        enable = true;
      };

      environment.systemPackages = with pkgs; [
        heroic
      ];
    };
}
