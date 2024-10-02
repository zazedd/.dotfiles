{ xdg_home, ... }:

let
  xdg_configHome = "${xdg_home}/.config";
  githubPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA47RV+m4PubAmG21MCU7KCyWEvrFS+HGfFloX16gUjx zazed@shitbook.local";
in
{

  "${xdg_home}/.ssh/id_github.pub" = {
    text = githubPublicKey;
  };

  "${xdg_configHome}/wezterm/wezterm.lua" = {
    text = builtins.readFile ../../configs/wezterm/wezterm.lua;
  };

  "${xdg_home}/.zsh/functions.zsh" = {
    text = builtins.readFile ../../configs/zsh/functions.zsh;
  };

  "${xdg_home}/.zsh/keys.zsh" = {
    text = builtins.readFile ../../configs/zsh/keys.zsh;
  };

  "${xdg_home}/.zsh/theme.zsh" = {
    text = builtins.readFile ../../configs/zsh/theme.zsh;
  };

  "${xdg_home}/.zsh/prompt.zsh" = {
    text = builtins.readFile ../../configs/zsh/prompt.zsh;
  };

  "${xdg_configHome}/starship.toml" = {
    text = builtins.readFile ../../configs/zsh/starship.toml;
  };

  "${xdg_home}/.zsh/vimode.zsh" = {
    text = builtins.readFile ../../configs/zsh/vimode.zsh;
  };
}
