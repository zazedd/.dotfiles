{
  lib,
  config,
  domain,
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

  cfg = config.my.reverse-proxy;

  serviceModule = types.submodule (
    { name, ... }:
    {
      options = {
        port = mkOption {
          type = types.port;
          description = "port for ${name}";
        };

        extraPort = mkOption {
          type = types.nullOr types.port;
          default = null;
          description = "extra port for ${name}";
        };

        aliases = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "additional DNS names pointing to ${name}";
        };

        public = mkOption {
          type = types.bool;
          default = true;
          description = "whether to expose via nginx";
        };

        extraLocations = mkOption {
          type = types.attrsOf types.anything;
          default = { };
          description = "additional nginx locations for this service (maps path to location attrs)";
        };
      };
    }
  );

  ports = mapAttrsToList (_: v: v.port) cfg;
  hostnames = flatten (mapAttrsToList (name: svc: [ name ] ++ svc.aliases) cfg);

  hostMap = flatten (
    mapAttrsToList (
      name: svc:
      if svc.public then
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

  # nginx generator
  mkProxy =
    {
      n,
      port,
      extraLocations,
    }:
    let
      default = {
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
      };
    in
    {
      name = "${n}.${domain}";
      value = {
        forceSSL = true;
        useACMEHost = "ff.${domain}";
        locations = default // extraLocations;
      };
    };
in
{
  options.my.reverse-proxy = mkOption {
    type = types.attrsOf serviceModule;
    default = { };
    description = "reverse proxy service registry.";
  };

  config = {

    assertions = [
      {
        assertion = length ports == length (unique ports);
        message = "duplicate ports detected";
      }
      {
        assertion = length hostnames == length (unique hostnames);
        message = "duplicate service or alias names detected";
      }
    ];

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
      // builtins.listToAttrs (map mkProxy hostMap);
    };
  };
}
