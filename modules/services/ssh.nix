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
        settings = {
          "github.com-ahrefs" = {
            header = ''Match host github.com exec "sh -c 'case $PWD in ${config.home.homeDirectory}/ahrefs*) exit 0 ;; *) exit 1 ;; esac'"'';
            HostName = "github.com";
            IdentitiesOnly = true;
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_ahrefs";
          };

          "github.com" = lib.hm.dag.entryAfter [ "github.com-ahrefs" ] {
            HostName = "github.com";
            IdentitiesOnly = true;
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_github";
          };

          "gitlab.com" = {
            HostName = "gitlab.com";
            IdentitiesOnly = true;
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_github";
          };

          nspawn = {
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_ahrefs";
            Include = "~/.ssh/ahrefs/per-user/spawnbox-devbox-uk-leonardosantos";
          };

          "nspawn-sg" = {
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_ahrefs";
            Include = "~/.ssh/ahrefs/per-user/spawnbox-devbox-sg-leonardosantos";
          };

          "nspawn-us" = {
            IdentityFile = "${config.home.homeDirectory}/.ssh/id_ahrefs";
            Include = "~/.ssh/ahrefs/per-user/spawnbox-devbox-us-leonardosantos";
          };
        };
      };
    };
}
