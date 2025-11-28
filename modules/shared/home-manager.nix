{
  config,
  pkgs,
  lib,
  gpgid ? null,
  nvidia ? false,
  ...
}:

let
  name = "zazed";
  user = "zazed";
  email = "leomendesantos@gmail.com";
  extra_sway = if nvidia then "--unsupported-gpu" else "";
in
{
  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    shellAliases = {
      v = "XDG_CONFIG_HOME='/home/${user}/.dotfiles/configs' nvim"; # set XDG_CONFIG_HOME here to update lock file correctly when updating
      t = "tmux new-session \; send-keys \"nvim\" C-m \; neww \; split-window -v \; selectp -t 1  \; selectw -t 1";

      # sudo alias hack
      sudo = "nocorrect sudo ";

      # utilities
      mv = "mv -iv";
      mkdir = "mkdir -p";
      nv = "nvim --clean";
      sl = "eza";
      ls = "eza";
      l = "eza -l";
      la = "eza -la";
      ip = "ip --color=auto";
      sw = "sway --config /home/${user}/.config/sway/config ${extra_sway}";
      du = "dua";

      gs = "git status";
      gcl = "git clone";

      weather = "curl v2.wttr.in";
      ff = "fastfetch";
      rr = "source ~/.zshrc";
    };
    plugins = [
      {
        name = "zsh-zoxide";
        src = pkgs.fetchFromGitHub {
          owner = "z-shell";
          repo = "zsh-zoxide";
          rev = "v1.2.0";
          sha256 = "xbchXJTFWeABTwq6h4KWLh+EvydDrDzcY9AQVK65RS8=";
        };
        file = "zsh-zoxide.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.8.0";
          sha256 = "iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
        };
        file = "zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-vi-mode";
        src = pkgs.fetchFromGitHub {
          owner = "jeffreytse";
          repo = "zsh-vi-mode";
          rev = "v0.11.0";
          sha256 = "xbchXJTFWeABTwq6h4KWLh+EvydDrDzcY9AQVK65RS8=";
        };
        file = "zsh-vi-mode.zsh";
      }
      {
        name = "zsh-autopair";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "v1.0";
          sha256 = "wd/6x2p5QOSFqWYgQ1BTYBUGNR06Pr2viGjV/JqoG8A=";
        };
        file = "autopair.zsh";
      }
      {
        name = "fzf";
        src = pkgs.fetchFromGitHub {
          owner = "unixorn";
          repo = "fzf-zsh-plugin";
          rev = "06e2946913500c34486764589b4bfb3e9d8c2058";
          sha256 = "Ubxakc8DwJoy49o3B5L+t5vZw3KA2VWvlAPGWER8J2A=";
        };
      }
    ];
    initContent = lib.mkOrder 1500 (builtins.readFile ../../configs/zsh/.zshrc);
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = "zazedd";
    userEmail = email;

    signing = {
      format = "openpgp";
      key = gpgid;
    };

    lfs = {
      enable = true;
    };
    extraConfig = {
      commit.gpgsign = gpgid != null;

      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };

      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  vim = {
    enable = true;
    settings = {
      ignorecase = true;
    };
    extraConfig = builtins.readFile ../../configs/vim/init.vim;
  };

  ssh = {
    enable = true;
    extraConfig = lib.mkMerge [
      ''
        Match host github.com exec "[[ $PWD == /home/${user}/ahrefs* ]]"
          Hostname github.com
          IdentitiesOnly yes
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux ''
        IdentityFile /home/${user}/.ssh/id_ahrefs
      '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
        IdentityFile /Users/${user}/.ssh/id_ahrefs
      '')

      ''
        Host github.com
          Hostname github.com
          IdentitiesOnly yes
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux ''
        IdentityFile /home/${user}/.ssh/id_github
      '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
        IdentityFile /Users/${user}/.ssh/id_github
      '')

      ''
        Host gitlab.com
          Hostname gitlab.com
          IdentitiesOnly yes
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux ''
        IdentityFile /home/${user}/.ssh/id_github
      '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
        IdentityFile /Users/${user}/.ssh/id_github
      '')

      ''
        Match all
          Include ~/.ssh/hop
          Include ~/.ssh/ahrefs/config
      ''

      ''
        Host nspawn
          Include ~/.ssh/ahrefs/per-user/spawnbox-devbox-uk-leonardosantos
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux ''
        IdentityFile /home/${user}/.ssh/id_ahrefs
      '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
        IdentityFile /Users/${user}/.ssh/id_ahrefs
      '')

    ];
  };
}
