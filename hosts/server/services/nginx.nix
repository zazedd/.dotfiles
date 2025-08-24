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
  }
  // builtins.listToAttrs (
    map mkProxy [
      "radarr"
      "sonarr"
      "prowlarr"
      "bazarr"
      "home"
      "deluge"
      "sabnzbd"
      "flaresolverr"
      "jellyfin"
      "watch" # also points to jellyfin
      # "dufs"
      "cloud" # also points to dufs
      "copyparty"
      "immich"
      "photos" # also points to immich
      "jellyseerr"
      "request" # also points to jellyseerr
    ]
  );
}
