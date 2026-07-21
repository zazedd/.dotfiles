{
  flake.modules.nixos.ssh = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  flake.modules.darwin.ssh = {
    services.openssh.enable = true;
  };

  flake.modules.homeManager.ssh =
    { lib, config, ... }:
    {
      programs.ssh = {
        enableDefaultConfig = false;
        enable = true;

        includes = [
          "~/.ssh/hop"
          "ahrefs/config"
        ];
        matchBlocks = {
          "github.com-ahrefs" = {
            match = ''host github.com exec "sh -c 'case $PWD in ${config.home.homeDirectory}/ahrefs*) exit 0 ;; *) exit 1 ;; esac'"'';
            hostname = "github.com";
            identitiesOnly = true;
            identityFile = "${config.home.homeDirectory}/.ssh/id_ahrefs";
          };

          "github.com" = lib.hm.dag.entryAfter [ "github.com-ahrefs" ] {
            hostname = "github.com";
            identitiesOnly = true;
            identityFile = "${config.home.homeDirectory}/.ssh/id_github";
          };

          "gitlab.com" = {
            hostname = "gitlab.com";
            identitiesOnly = true;
            identityFile = "${config.home.homeDirectory}/.ssh/id_github";
          };

          "nspawn" = {
            identityFile = "${config.home.homeDirectory}/.ssh/id_ahrefs";
            extraOptions = {
              Include = "~/.ssh/ahrefs/per-user/spawnbox-devbox-uk-leonardosantos";
            };
          };

          "nspawn-sg" = {
            identityFile = "${config.home.homeDirectory}/.ssh/id_ahrefs";
            extraOptions = {
              Include = "~/.ssh/ahrefs/per-user/spawnbox-devbox-sg-leonardosantos";
            };
          };
        };
      };
    };
}
