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

  homeDir = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${user}" else "/home/${user}";
in
{
  git = {
    enable = true;
    ignores = [ "*.swp" ];
    settings = {
      user = {
        name = "zazedd";
        email = email;
      };

      commit.gpgsign = gpgid != null;

      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };

      pull.rebase = true;
      rebase.autoStash = true;
    };

    signing = {
      format = "openpgp";
      key = gpgid;
    };

    lfs = {
      enable = true;
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
    enableDefaultConfig = false;
    enable = true;

    includes = [
      "~/.ssh/hop"
      "~/.ssh/ahrefs/config"
    ];
    matchBlocks = {
      "github.com-ahrefs" = {
        match = ''host github.com exec "[[ $PWD == ${homeDir}/ahrefs* ]]"'';
        hostname = "github.com";
        identitiesOnly = true;
        identityFile = "${homeDir}/.ssh/id_ahrefs";
      };

      "github.com" = lib.hm.dag.entryAfter [ "github.com-ahrefs" ] {
        hostname = "github.com";
        identitiesOnly = true;
        identityFile = "${homeDir}/.ssh/id_github";
      };

      "gitlab.com" = {
        hostname = "gitlab.com";
        identitiesOnly = true;
        identityFile = "${homeDir}/.ssh/id_github";
      };

      "nspawn" = {
        identityFile = "${homeDir}/.ssh/id_ahrefs";
        extraOptions = {
          Include = "~/.ssh/ahrefs/per-user/spawnbox-devbox-uk-leonardosantos";
        };
      };
    };
  };

  # shared shell configuration
  zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    shellAliases = {
      v = "XDG_CONFIG_HOME='/home/${user}/.dotfiles/configs' nvim"; # set XDG_CONFIG_HOME here to update lock file correctly when updating
      nvim = "XDG_CONFIG_HOME='/home/${user}/.dotfiles/configs' nvim";
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
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "zsh-vi-mode.zsh";
      }
      {
        name = "zsh-autopair";
        src = pkgs.zsh-autopair;
        file = "autopair.zsh";
      }
      {
        name = "fzf";
        src = pkgs.fzf-zsh-plugin;
        file = "fzf-zsh-plugin.zsh";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ../../configs/zsh;
        file = ".p10k.zsh";
      }
    ];

    initContent = lib.mkOrder 1500 (builtins.readFile ../../configs/zsh/.zshrc);

    syntaxHighlighting = {
      enable = true;
      styles = {
        # core text
        default = "fg=#C5C9C5"; # fujiWhite
        unknown-token = "fg=#C4746E,bold"; # autumnRed (errors)

        # shell structure
        reserved-word = "fg=#C4B28A,bold"; # roninYellow
        commandseparator = "fg=#7AA89F,bold"; # waveAqua2
        redirection = "fg=#7AA89F,bold";
        assign = "fg=#B6927B"; # autumnYellow

        # commands
        command = "fg=#87A987,bold"; # dragonGreen
        builtin = "fg=#8BA4B0,bold"; # dragonBlue
        function = "fg=#A292A3,bold"; # dragonPurple
        alias = "fg=#C4B28A,bold";
        suffix-alias = "fg=#C4B28A";
        global-alias = "fg=#C4B28A";
        precommand = "fg=#7AA89F";
        hashed-command = "fg=#87A987";
        autodirectory = "fg=#8EA4A2,underline";

        # arguments & options
        single-hyphen-option = "fg=#8BA4B0";
        double-hyphen-option = "fg=#8BA4B0";
        arg0 = "fg=#87A987,bold";

        # strings
        single-quoted-argument = "fg=#87A987";
        double-quoted-argument = "fg=#87A987";
        dollar-quoted-argument = "fg=#87A987";
        single-quoted-argument-unclosed = "fg=#C4746E,bold";
        double-quoted-argument-unclosed = "fg=#C4746E,bold";
        dollar-quoted-argument-unclosed = "fg=#C4746E,bold";

        # substitutions
        command-substitution = "fg=#8BA4B0";
        command-substitution-delimiter = "fg=#7AA89F";
        process-substitution = "fg=#8BA4B0";
        process-substitution-delimiter = "fg=#7AA89F";
        arithmetic-expansion = "fg=#B6927B";
        back-quoted-argument = "fg=#8BA4B0";
        back-quoted-argument-delimiter = "fg=#7AA89F";

        # paths
        path = "fg=#8EA4A2,underline";
        path_prefix = "fg=#8EA4A2";
        path_pathseparator = "fg=#7AA89F";
        path_prefix_pathseparator = "fg=#7AA89F";

        # globbing & history
        globbing = "fg=#A292A3";
        history-expansion = "fg=#C4746E,bold";

        # comments
        comment = "fg=#737C73,italic"; # dragonAsh

        # file descriptors
        named-fd = "fg=#B6927B";
        numeric-fd = "fg=#B6927B";
      };
    };
  };

}
