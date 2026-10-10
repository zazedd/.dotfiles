{ inputs, config, ... }:
let
  email = config.flake.meta.users.zazed.email;
in
{
  flake.modules.nixos.reverse-proxy =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        mkOption
        types
        mapAttrsToList
        flatten
        unique
        length
        ;

      cfg = config.registry;
      domain = config.domain;

      nginxLocationModule =
        import "${pkgs.path}/nixos/modules/services/web-servers/nginx/location-options.nix"
          {
            inherit lib config;
          };

      serviceModule = types.submodule (
        { name, ... }:
        {
          options = {
            port = mkOption {
              type = types.port;
              description = "port for ${name}";
            };
            aliases = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "additional DNS names pointing to ${name}";
            };
            exposure = mkOption {
              type = types.enum [
                "tailnet"
                "local"
              ];
              default = "tailnet";
              description = "whether ${name} is exposed through nginx on the tailnet or remains local-only";
            };
            extraLocations = mkOption {
              type = types.attrsOf (types.submodule nginxLocationModule);
              default = { };
              description = "additional typed nginx locations for ${name}";
            };
          };
        }
      );

      ports = mapAttrsToList (_: v: v.port) cfg;
      hostnames = flatten (mapAttrsToList (name: svc: [ name ] ++ svc.aliases) cfg);
      tailnetHosts = flatten (
        mapAttrsToList (
          name: svc:
          if svc.exposure == "tailnet" then
            let
              names = [ name ] ++ svc.aliases;
            in
            map (n: {
              inherit n;
              port = svc.port;
              extraLocations = svc.extraLocations;
            }) names
          else
            [ ]
        ) cfg
      );

      mkProxy =
        {
          n,
          port,
          extraLocations,
        }:
        {
          name = "${n}.${domain}";
          value = {
            forceSSL = true;
            useACMEHost = "ff.${domain}";
            locations = {
              "/" = {
                proxyPass = "http://127.0.0.1:${toString port}/";
                proxyWebsockets = true;
                extraConfig = ''
                  client_max_body_size 50000M;
                  proxy_read_timeout   600s;
                  proxy_send_timeout   600s;
                  send_timeout         600s;
                '';
              };
            }
            // extraLocations;
          };
        };
    in
    {
      options.registry = mkOption {
        type = types.attrsOf serviceModule;
        default = { };
        description = "service registry for local and tailnet-routed services";
      };

      config = {
        assertions = [
          {
            assertion = length ports == length (unique ports);
            message = "duplicate ports detected in reverse-proxy";
          }
          {
            assertion = length hostnames == length (unique hostnames);
            message = "duplicate service or alias names detected in reverse-proxy";
          }
        ];

        sops.secrets."cloudflare-api" = { };

        security.acme = {
          acceptTerms = true;
          certs = {
            "ff.${domain}" = {
              inherit email;
              domain = "*.${domain}";
              group = "nginx";
              dnsProvider = "cloudflare";
              dnsResolver = "1.1.1.1:53";
              environmentFile = config.sops.secrets."cloudflare-api".path;
              webroot = null;
            };
          };
        };

        services.nginx = {
          enable = true;
          recommendedProxySettings = true;
          recommendedTlsSettings = true;
          virtualHosts = {
            "ff.${domain}" = {
              enableACME = true;
              forceSSL = true;
            };
          }
          // builtins.listToAttrs (map mkProxy tailnetHosts);
        };
      };
    };
}
