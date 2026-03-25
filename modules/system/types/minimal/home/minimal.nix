{ config, ... }:
# default settings needed for all homeManagerConfigurations
{
  flake.modules.homeManager.system-minimal =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.stateVersion = "25.11";
      home.homeDirectory = lib.mkForce (
        if pkgs.stdenv.isDarwin
        then "/Users/${config.home.username}"
        else "/home/${config.home.username}"
      );
    };
}
