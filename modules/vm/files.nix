{ user, ... }:

let
  home           = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";
  xdg_dataHome   = "${home}/.local/share";
  xdg_stateHome  = "${home}/.local/state"; in
{

  "${xdg_configHome}/bspwm/bspwmrc" = {
    executable = true;
    text = builtins.readFile ../../configs/bspwm/bspwmrc;
  };

  "${xdg_configHome}/sxhkd/sxhkdrc" = {
    executable = true;
    text = builtins.readFile ../../configs/sxhkd/sxhkdrc;
  };
}
