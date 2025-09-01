{ ports, domain, ... }:
let
  mkProxy =
    name:
    let
      port = toString ports.${name};
    in
    {
      name = "${name}.${domain}";
      value = {
        forceSSL = true;
        sslCertificate = "/var/lib/acme/ff.${domain}/fullchain.pem";
        sslCertificateKey = "/var/lib/acme/ff.${domain}/key.pem";
        locations."/" = {
          proxyPass = "http://127.0.0.1:${port}/";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 50000M;
            proxy_read_timeout   600s;
            proxy_send_timeout   600s;
            send_timeout         600s;
          '';
        };
      };
    };
in
{
  enable = true;
  recommendedProxySettings = true;
  recommendedTlsSettings = true;
  virtualHosts = {
    "ff.${domain}" = {
      forceSSL = true;
      enableACME = true;
    };

    "watch.${domain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/ff.${domain}/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/ff.${domain}/key.pem";
      locations."/socket" = {
        proxyPass = "http://127.0.0.1:${ports.watch}/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Protocol $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
        '';
      };

    };
  }
  // builtins.listToAttrs (
    map mkProxy [
      "bitwarden"

      "radarr"
      "sonarr"
      "lidarr"
      "prowlarr"
      "bazarr"

      "home"

      "deluge"
      "sabnzbd"
      "flaresolverr"

      "jellyfin"
      "watch" # also points to jellyfin

      # "dufs"
      "cloud" # also points to copyparty
      "copyparty"

      "immich"
      "photos" # also points to immich

      "jellyseerr"
      "request" # also points to jellyseerr
    ]
  );
}
