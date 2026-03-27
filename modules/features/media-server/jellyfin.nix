{
  flake.modules.nixos.mediaserver = {
    services.jellyfin = {
      enable = true;
      user = "media";
      group = "media";
    };

    services.jellyseerr.enable = true;
  };

  flake.modules.nixos.reverse-proxy = {
    registry.jellyfin = {
      port = 8096;
      aliases = [ "watch" ];
      extraLocations = {
        "/socket" = {
          proxyPass = "http://127.0.0.1:8096/";
          proxyWebsockets = true;
          extraConfig = ''
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
    };
  };
}
