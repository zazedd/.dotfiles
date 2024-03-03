{ user, config, pkgs, ... }:

let
  xdg_configHome = "${config.users.users.${user}.home}/.config";
  xdg_dataHome   = "${config.users.users.${user}.home}/.local/share";
  xdg_stateHome  = "${config.users.users.${user}.home}/.local/state"; 
in
{

  "${xdg_configHome}/yabai/yabairc" = {
    text = builtins.readFile ../../configs/yabai/yabairc;
  };

  "${xdg_configHome}/skhd/skhdrc" = {
    text = builtins.readFile ../../configs/skhd/skhdrc;
  };

  # Raycast script so that "Run Emacs" is available and uses Emacs daemon
  "${xdg_dataHome}/bin/nvimclient" = {
    executable = true;
    text = ''
      #!/bin/zsh
      #
      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title Run Nvim
      # @raycast.mode silent
      #
      # Optional parameters:
      # @raycast.packageName Nvim

      ${pkgs.neovim}/bin/nvim 
    '';
  };
}
