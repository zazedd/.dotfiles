{
  config,
  domain,
  ports,
  lib,
  ...
}:
{
  sops.secrets."glance-env" = { };
  systemd.services.glance.serviceConfig.EnvironmentFile =
    lib.mkForce
      config.sops.secrets."glance-env".path;

  services.glance =
    let
      mkSite = name: {
        title = name;
        url = "https://${name}.leoms.dev";
        icon = "si:${name}";
      };

      mkSiteNoIcon = name: {
        title = name;
        url = "https://${name}.leoms.dev";
        icon = "si:onnx";
      };
    in
    {
      enable = true;
      settings = {
        server = {
          port = ports.home;
        };
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "clock";
                    hour-format = "24h";
                    timezones = [
                      {

                        timezone = "Europe/Lisbon";
                        label = "Portugal";
                      }
                      {
                        timezone = "Asia/Singapore";
                        label = "Singapore";
                      }
                    ];

                  }
                  {
                    type = "calendar";
                    first-day-of-week = "sunday";
                  }
                  {
                    type = "server-stats";
                    servers = [
                      {
                        type = "local";
                        name = "xinho";
                      }
                    ];
                  }

                  {
                    type = "custom-api";
                    title = "SABnzbd Status";
                    cache = "30s";
                    url = "https://sabnzbd.leoms.dev/api?output=json&apikey=\${SABNZBD_API}&mode=queue";
                    headers = {
                      Accept = "application/json";
                    };
                    template = ''
                      <div class="p-2">
                        <div class="flex justify-between mb-2">
                          <div class="flex-1">
                            <div class="size-h6">SPEED</div>
                            <div class="color-highlight size-h3">{{ if eq (.JSON.String "queue.status") "Downloading" }}{{ .JSON.String "queue.speed" }}B/s{{ else }}Paused{{ end }}</div>
                          </div>
                          <div class="flex-1">
                            <div class="size-h6">TIME LEFT</div>
                            <div class="color-highlight size-h3">{{ if eq (.JSON.String "queue.status") "Downloading" }}{{ .JSON.String "queue.timeleft" }}{{ else }}--:--:--{{ end }}</div>
                          </div>
                        </div>
                        <div class="flex justify-between mb-2">
                          <div class="flex-1">
                            <div class="size-h6">QUEUE</div>
                            <div class="color-highlight size-h3">{{ .JSON.Int "queue.noofslots" }} items</div>
                          </div>
                          <div class="flex-1">
                            <div class="size-h6">SIZE</div>
                            <div class="color-highlight size-h3">{{ .JSON.Float "queue.mb" | printf "%.1f" }}MB</div>
                          </div>
                        </div>
                      </div>
                    '';
                  }
                ];
              }

              {
                size = "full";
                widgets = [
                  {
                    type = "search";
                    search-engine = "google";
                  }
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services";
                    sites =
                      map mkSite [
                        "jellyfin"
                        "radarr"
                        "sonarr"
                      ]
                      ++ map mkSiteNoIcon [
                        "bazarr"
                        "jellyseerr"
                        "prowlarr"
                        "cloud"
                        "sabnzbd"
                        "deluge"
                      ];
                  }

                  {
                    type = "lobsters";
                    sort-by = "hot";
                    tags = [
                      "linux"
                      "ml"
                      "haskell"
                      "vim"
                      "programming"
                      "formalmethods"
                      "compsci"
                      "math"
                      "plt"
                      "nix"
                    ];
                    limit = 30;
                    collapse-after = 5;
                  }

                  {
                    type = "group";
                    widgets = [
                      {
                        type = "reddit";
                        subreddit = "homelab";
                        style = "horizontal-cards";
                      }

                      {
                        type = "reddit";
                        subreddit = "usenetinvites";
                        style = "horizontal-cards";
                      }

                      {
                        type = "reddit";
                        subreddit = "selfhosted";
                        style = "horizontal-cards";
                      }

                      {
                        type = "reddit";
                        subreddit = "ocaml";
                        style = "horizontal-cards";
                      }
                    ];
                  }

                  {
                    type = "custom-api";
                    frameless = true;
                    title = "jellyfin history";
                    cache = "5m";
                    url = "https://jellyfin.${domain}/Users/\${JELLYFIN_USER_ID}/Items";
                    parameters = {
                      api_key = "\${JELLYFIN_KEY}";
                      Limit = 10; # Modify this value for the length of the history
                      IncludeItemTypes = "Movie,Episode";
                      Recursive = true;
                      isPlayed = true;
                      SortBy = "DatePlayed";
                      SortOrder = "Descending";
                    };
                    subrequests = {
                      user = {
                        url = "https://jellyfin.${domain}/Users/\${JELLYFIN_USER_ID}";
                        parameters = {
                          api_key = "\${JELLYFIN_KEY}";
                        };
                      };
                    };
                    template = builtins.readFile ../../../configs/glance/template_jellyfin.go;
                  }

                  {
                    type = "hacker-news";
                    limit = 15;
                    collapse-after = 5;
                  }
                ];
              }

              {
                size = "small";
                widgets = [
                  {
                    type = "weather";
                    location = "Porto, Portugal";
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        title = "Work/School";
                        color = "10 70 50";
                        links = [
                          {
                            title = "Gmail";
                            url = "https://mail.google.com/mail/u/0/";
                          }

                          {
                            title = "Github";
                            url = "https://github.com/";
                          }

                          {
                            title = "MyNixOS";
                            url = "https://mynixos.com/";
                          }

                          {
                            title = "Moodle";
                            url = "https://moodle2425.up.pt/";
                          }
                        ];
                      }

                      {
                        title = "Entertainment/Social";
                        color = "200 50 50";
                        links = [
                          {
                            title = "Youtube";
                            url = "https://youtube.com/";
                          }

                          {
                            title = "Reddit";
                            url = "https://reddit.com/";
                          }
                        ];
                      }
                    ];
                  }

                  {
                    type = "markets";
                    hide-header = true;
                    markets = [
                      {
                        symbol = "VWCE.DE";
                        name = "VWCE";
                      }

                      {
                        symbol = "BTC-EUR";
                        name = "Bitcoin";
                      }

                      {
                        symbol = "ADA-EUR";
                        name = "Cardano";
                      }
                    ];
                  }

                  {
                    type = "custom-api";
                    height = "200px";
                    title = "Random Cat";
                    cache = "2m";
                    url = "https://cataas.com/cat?json=true";
                    template = ''
                      <img src="{{ .JSON.String "url" }}"></img>
                    '';
                  }
                ];
              }
            ];
          }
        ];
      };
    };
}
