{ user, config, pkgs, ... }:

let
  xdg_configHome = "${config.users.users.${user}.home}/.config";
  xdg_dataHome   = "${config.users.users.${user}.home}/.local/share";
  xdg_stateHome  = "${config.users.users.${user}.home}/.local/state"; 
in
{
  "${xdg_configHome}/alacritty/alacritty.toml" = {
    text = builtins.readFile ../../configs/alacritty/alacritty.toml;
  };
}
