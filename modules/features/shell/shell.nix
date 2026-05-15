{
  self,
  config,
  ...
}:
let
  name = config.flake.meta.users.zazed.name;
  email = config.flake.meta.users.zazed.email;
  home =
    isDarwin:
    if isDarwin then
      config.flake.meta.users.zazed.homeDarwin
    else
      config.flake.meta.users.zazed.homeLinux;
in
{
  flake.modules.nixos.shell =
    { pkgs, ... }:
    {
      fonts = {
        packages = [
          pkgs.nerd-fonts.iosevka
        ];

        fontconfig.defaultFonts = {
          monospace = [ "Iosevka Nerd Font Mono" ];
          sansSerif = [ "Iosevka Nerd Font" ];
          serif = [ "Iosevka Nerd Font" ];
        };
      };
    };

  flake.modules.darwin.shell =
    { pkgs, ... }:
    {
      fonts.packages = [
        pkgs.nerd-fonts.iosevka
      ];
    };

  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      programs = {
        git = {
          enable = true;
          ignores = [ "*.swp" ];
          settings = {
            user = {
              inherit email;
              name = "zazedd";
            };

            # commit.gpgsign = gpgid != null;

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
            # key = gpgid;
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
          extraConfig = builtins.readFile ../../../configs/vim/init.vim;
        };
      };
    };

  flake.wrappers.fish =
    {
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.fish ];
      package = pkgs.fish;
      shellAliases = {
        v = "XDG_CONFIG_HOME='${home pkgs.stdenv.isDarwin}/.dotfiles/configs' command nvim"; # set XDG_CONFIG_HOME here to update lock file correctly when updating
        nvim = "XDG_CONFIG_HOME='${home pkgs.stdenv.isDarwin}/.dotfiles/configs' command nvim";

        # utilities
        mv = "mv -iv";
        mkdir = "mkdir -p";
        nv = "nvim --clean";
        sl = "${lib.getExe pkgs.eza}";
        ls = "${lib.getExe pkgs.eza}";
        l = "${lib.getExe pkgs.eza} -l";
        la = "${lib.getExe pkgs.eza} -la";
        du = "${lib.getExe pkgs.dua}";
        ip = "ip --color=auto";

        weather = "curl v2.wttr.in";
        ff = "fastfetch";
      };
      env = {
        HISTIGNORE = "pwd:ls:cd";
        EDITOR = "nvim";
        GIT_EDITOR = "nvim --clean";
      };
      plugins = [
        pkgs.fishPlugins.hydro
        pkgs.fishPlugins.fzf-fish
        pkgs.fishPlugins.autopair
      ];
      configFile.content = /* fish */ ''
        fish_add_path /run/current-system/sw/bin
        fish_add_path /nix/var/nix/profiles/default/bin
        fish_add_path $HOME/.nix-profile/bin

        set -gx GPG_TTY (tty)
        set -g fish_greeting ""
        set -g fish_history fish
        fzf_configure_bindings --directory=ctrl-t
        bind \e\[127\;5u backward-kill-word

        # fish default theme colors (set globally since --no-config skips universal vars)
        set -g fish_color_normal normal
        set -g fish_color_command blue
        set -g fish_color_keyword blue
        set -g fish_color_quote yellow
        set -g fish_color_redirection cyan
        set -g fish_color_end green
        set -g fish_color_error brred
        set -g fish_color_param normal
        set -g fish_color_comment brblack
        set -g fish_color_operator brcyan
        set -g fish_color_escape brcyan
        set -g fish_color_autosuggestion brblack
        set -g fish_color_cancel -r
        set -g fish_color_cwd green
        set -g fish_color_user brgreen
        set -g fish_color_host normal
        set -g fish_color_host_remote yellow
        set -g fish_color_status red
        set -g fish_color_valid_path --underline
        set -g fish_color_match --background=brblue
        set -g fish_color_selection white --bold --background=brblack
        set -g fish_color_search_match bryellow --background=brblack
        set -g fish_pager_color_progress brwhite --background=cyan
        set -g fish_pager_color_prefix white --bold --underline
        set -g fish_pager_color_completion normal
        set -g fish_pager_color_description yellow --dim
        set -g fish_pager_color_selected_background -r

        if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
            source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
            source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
        end

        function nix-shell-dev
            set -l dev_installables
            set -l shell_installables

            for pkg in $argv
                set -a dev_installables "nixpkgs#$pkg.dev"
                set -a shell_installables "nixpkgs#$pkg"
            end

            set -l dev_paths (
                nix build --no-link --print-out-paths $dev_installables
            )

            set -l extra_ld (
                printf "%s\n" $dev_paths | awk '{print $0 "/lib"}' | paste -sd:
            )

            set -l extra_pc (
                printf "%s\n" $dev_paths | awk '{print $0 "/lib/pkgconfig"}' | paste -sd:
            )

            env \
                LD_LIBRARY_PATH="$extra_ld$(
                    test -n "$LD_LIBRARY_PATH"; and echo ":$LD_LIBRARY_PATH"
                )" \
                PKG_CONFIG_PATH="$extra_pc$(
                    test -n "$PKG_CONFIG_PATH"; and echo ":$PKG_CONFIG_PATH"
                )" \
                nix shell $shell_installables
        end

        # universal extract command
        function ext
            if test -f "$argv[1]"
                set -l file "$argv[1]"

                if test -n "$argv[2]"
                    set file "../$argv[1]"
                    mkdir -p "$argv[2]"
                    cd "$argv[2]"
                end

                switch "$argv[1]"
                    case "*.tar.bz2"
                        tar xvjf "$file"

                    case "*.tar.gz"
                        tar xvzf "$file"

                    case "*.tar.xz"
                        tar xvf "$file"

                    case "*.bz2"
                        bunzip2 -v "$file"

                    case "*.rar"
                        rar x "$file"

                    case "*.gz"
                        gunzip -v "$file"

                    case "*.tar"
                        tar xvf "$file"

                    case "*.tbz2"
                        tar xvjf "$file"

                    case "*.tgz"
                        tar xvzf "$file"

                    case "*.zip"
                        unzip "$file"

                    case "*.Z" "*.z"
                        uncompress "$file"

                    case "*.7z"
                        7z x "$file"

                    case '*'
                        echo "'$argv[1]' cannot be extracted via ext()"
                end

                if test -n "$argv[2]"
                    cd ..
                end
            else
                echo "'$argv[1]' is not a valid file"
            end
        end
      '';
    };
}
