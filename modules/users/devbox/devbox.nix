{ self, ... }:
{
  flake.modules.homeManager.devbox = {
    imports = with self.modules.homeManager; [
      system-minimal
      shell
    ];

    home.username = "me";

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };

    programs.bash.initExtra = ''
      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    '';

    # Home Manager owns .profile; restore Nix setup for login shells (including tmux).
    programs.bash.profileExtra = ''
      if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        # /etc/profile may reset PATH even when this guard is inherited from the parent.
        unset __ETC_PROFILE_NIX_SOURCED
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
    '';
  };
}
