{ xdg_home, ... }:

let
  xdg_configHome = "${xdg_home}/.config";
  githubPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA47RV+m4PubAmG21MCU7KCyWEvrFS+HGfFloX16gUjx zazed@shitbook.local";

  configRoot = ../../configs;
  mkZsh =
    paths:
    builtins.listToAttrs (
      map (p: {
        name = "${xdg_home}/.zsh${p}";
        value = {
          text = builtins.readFile (configRoot + /zsh + p);
        };
      }) paths
    );
in
mkZsh [
  "/functions.zsh"
  "/keys.zsh"
  "/theme.zsh"
  "/prompt.zsh"
  "/vimode.zsh"
]
// {
  "${xdg_home}/.ssh/id_github.pub" = {
    text = githubPublicKey;
  };

  "${xdg_configHome}/starship.toml" = {
    text = builtins.readFile ../../configs/zsh/starship.toml;
  };
}
