{ user, pkgs, config, ... }:

let
  xdg_configHome = "${config.users.users.${user}.home}/.config";
  xdg_home = "${config.users.users.${user}.home}";
  githubPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIe2iEv5koQmvSw0TShBa/TGve/onUZJuMOM9XjIZnJM leomendesantos@gmail.com";
in
{

  "${xdg_home}/.ssh/id_github.pub" = {
    text = githubPublicKey;
  };

  "${xdg_configHome}/wezterm/wezterm.lua" = {
    text = builtins.readFile ../../configs/wezterm/wezterm.lua;
  };

  "${xdg_home}/.zsh/alias.zsh" = {
    text = builtins.readFile ../../configs/zsh/alias.zsh;
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