{
  user,
  config,
  pkgs,
  ...
}:

let
  xdg_configHome = "${config.users.users.${user}.home}/.config";
  xdg_dataHome = "${config.users.users.${user}.home}/.local/share";
  xdg_stateHome = "${config.users.users.${user}.home}/.local/state";

  configRoot = ../../configs;
  mk =
    paths:
    builtins.listToAttrs (
      map (p: {
        name = "${xdg_configHome}${p}";
        value = {
          text = builtins.readFile (configRoot + p);
        };
      }) paths
    );
in
mk [
  "/alacritty/alacritty.toml"
  "/waybar/config"
  "/waybar/style.css"
]
