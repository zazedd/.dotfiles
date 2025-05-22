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
        locations."/".proxyPass = "http://127.0.0.1:${port}/";
      };
    };
in
{
  enable = true;
  recommendedProxySettings = true;
  recommendedTlsSettings = true;
  virtualHosts =
    {
      "cloud.${domain}" = {
        forceSSL = true;
        # enableACME = true;
        sslCertificate = "/var/lib/acme/ff.${domain}/fullchain.pem";
        sslCertificateKey = "/var/lib/acme/ff.${domain}/key.pem";
        locations = {
          "/" = {
            proxyPass = "http://unix:/run/seahub/gunicorn.sock";
            extraConfig = ''
              proxy_set_header   X-Real-IP $remote_addr;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header   X-Forwarded-Host $server_name;
              proxy_read_timeout  1200s;
              client_max_body_size 0;
            '';
          };
          "/seafhttp" = {
            proxyPass = "http://127.0.0.1:8082/";
            extraConfig = ''
              rewrite ^/seafhttp(.*)$ $1 break;
              client_max_body_size 0;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_connect_timeout  36000s;
              proxy_read_timeout  36000s;
              proxy_send_timeout  36000s;
              send_timeout  36000s;
            '';
          };
        };
      };

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
        "deluge"
        "sabnzbd"
        "flaresolverr"
        "jellyfin"
        "watch" # also points to jellyfin
        "jellyseerr"
        "request" # also points to jellyseerr
        "bazarr"
        "home"
      ]
    );
}
