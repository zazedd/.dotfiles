{ config, ... }:
{
  flake.wrappers.noctalia =
    { wlib, ... }:
    {
      imports = [ wlib.wrapperModules.noctalia-shell ];
      settings = (builtins.readFile ./noctalia.json |> builtins.fromJSON).settings // {
        wallpaper.defaultWallpaper = toString config.flake.meta.wallpaper;
      };
    };
}
