{ pkgs, config, ... }:
# default settings needed for all homeManagerConfigurations
{
  flake.meta.home = {
    dir =
      if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";
  };
  flake.modules.homeManager.system-minimal =
    {
      config,
      lib,
      ...
    }:
    {
      home.stateVersion = "25.11";
      home.homeDirectory = lib.mkForce config.flake.meta.home.dir;
    };
}
