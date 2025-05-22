{
  pkgs,
  config,
  ...
}:

let
  mediaDefaults = {
    enable = true;
    user = "media";
    group = "media";
  };
  ports = import ./ports.nix;
in
{
  users.users.media = {
    isSystemUser = true;
    description = "media user for arr services";
    group = "media";
  };

  users.groups.media = { };

  services.jellyfin = mediaDefaults;
  services.sonarr = mediaDefaults;
  services.radarr = mediaDefaults;

  services.prowlarr.enable = true;

  services.deluge = {
    enable = true;
    group = "media";
    openFirewall = true;
    web = {
      enable = true;
      openFirewall = true;
      port = ports.deluge;
    };
  };
  services.sabnzbd = mediaDefaults;

  services.flaresolverr.enable = true;

  services.jellyseerr.enable = true;
  services.bazarr = mediaDefaults;

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
                    url = "https://sabnzbd.leoms.dev/api?output=json&apikey=${
                      builtins.readFile config.sops.secrets."sabnzbd-api".path
                    }&mode=queue";
                    headers = [
                      {
                        Accept = "application/json";
                      }

                    ];
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
                ];
              }
            ];
          }
        ];
      };
    };
}
