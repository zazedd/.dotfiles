{ config, pkgs, lib, ... }:

let name = "zazed";
    user = "zazed";
    email = "leomendesantos@gmail.com"; in
{

  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    shellAliases = {
      sl = "eza";
      ls = "eza";
      l = "eza -l";
      la = "eza -la";
      ip = "ip --color=auto";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "sudo" "git" "z" ];
    };
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.6.0";
          sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
        };
        file = "zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-autopair";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
        file = "autopair.zsh";
      }
    ];
    initExtraFirst = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      export PATH=$PATH:/run/current-system/sw/bin

      export ZSH="$HOME/.oh-my-zsh"
      zstyle ':omz:update' mode reminder  # just remind me to update when it's time
      COMPLETION_WAITING_DOTS="true"

      export HISTIGNORE="pwd:ls:cd"

      export EDITOR="nvim"

      zstyle ':completion:*' menu select

      # nix shortcuts
      shell() {
          nix-shell '<nixpkgs>' -A "$1"
      }

      source ~/.zsh/theme.zsh
      source ~/.zsh/keys.zsh
      source ~/.zsh/vimode.zsh
      source ~/.zsh/functions.zsh
      source ~/.zsh/alias.zsh
      source ~/.zsh/prompt.zsh
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = "zazedd";
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = { 
	    editor = "nvim";
        autocrlf = "input";
      };
      commit.gpgsign = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  vim = {
    enable = true;
    settings = { ignorecase = true; };
    extraConfig = builtins.readFile ../../configs/vim/init.vim;
  };

  ssh = {
    enable = true;
    extraConfig = lib.mkMerge [
      ''
        Host github.com
          Hostname github.com
          IdentitiesOnly yes
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        ''
            IdentityFile /home/${user}/.ssh/id_github
        '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        ''
            IdentityFile /Users/${user}/.ssh/id_github
        '')
    ];
  };

}
