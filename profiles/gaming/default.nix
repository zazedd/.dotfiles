{ pkgs, config, ... }:
{
  imports = [ ];

  config = {
    programs.gamemode.enable = true; # for performance mode

    programs.steam = {
      enable = true;
    };
  };
}
