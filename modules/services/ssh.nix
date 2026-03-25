{
  inputs,
  config,
  lib,
  ...
}:
{
  flake.modules.nixos.ssh = {
    services.openssh.enable = true;
  };

  flake.modules.darwin.ssh = {
    services.openssh.enable = true;
  };

  flake.modules.homeModules.ssh = {
    programs.ssh = {
      enableDefaultConfig = false;
      enable = true;

      includes = [
        "~/.ssh/hop"
        "~/.ssh/ahrefs/config"
      ];
      matchBlocks = {
        "github.com-ahrefs" = {
          match = ''host github.com exec "[[ $PWD == ${config.flake.meta.home.dir}/ahrefs* ]]"'';
          hostname = "github.com";
          identitiesOnly = true;
          identityFile = "${config.flake.meta.home.dir}/.ssh/id_ahrefs";
        };

        "github.com" = lib.hm.dag.entryAfter [ "github.com-ahrefs" ] {
          hostname = "github.com";
          identitiesOnly = true;
          identityFile = "${config.flake.meta.home.dir}/.ssh/id_github";
        };

        "gitlab.com" = {
          hostname = "gitlab.com";
          identitiesOnly = true;
          identityFile = "${config.flake.meta.home.dir}/.ssh/id_github";
        };

        "nspawn" = {
          identityFile = "${config.flake.meta.home.dir}/.ssh/id_ahrefs";
          extraOptions = {
            Include = "~/.ssh/ahrefs/per-user/spawnbox-devbox-uk-leonardosantos";
          };
        };
      };
    };
  };
}
