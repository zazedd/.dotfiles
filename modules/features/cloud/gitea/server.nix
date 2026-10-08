{
  flake.modules.nixos.cloud =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      repositoryRoot = "/data/cloud/git";
      prepareRepositories = pkgs.writeShellScript "gitea-prepare-repositories" ''
        ${pkgs.coreutils}/bin/install -d -m 0750 -o gitea -g cloud ${repositoryRoot}
      '';
    in
    {
      services.gitea = {
        enable = true;
        appName = "leoms.dev Git";
        group = "cloud";
        stateDir = "/var/lib/gitea";
        customDir = "/var/lib/gitea/custom";
        inherit repositoryRoot;
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = "git.leoms.dev";
            ROOT_URL = "https://git.leoms.dev/";
            HTTP_ADDR = "127.0.0.1";
            HTTP_PORT = config.registry.git.port;
            SSH_DOMAIN = "git.leoms.dev";
          };
          service.DISABLE_REGISTRATION = true;
          repository = {
            DEFAULT_PRIVATE = "public";
            ENABLE_PUSH_CREATE_USER = true;
          };
        };
      };

      systemd.services.gitea = {
        unitConfig.RequiresMountsFor = [ "/data/cloud" ];

        # Create the external repository root as gitea:cloud before startup.
        serviceConfig.ExecStartPre = lib.mkBefore [ "+${prepareRepositories}" ];
      };
    };
}
