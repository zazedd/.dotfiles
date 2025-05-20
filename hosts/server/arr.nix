{
  pkgs,
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
            head-widgets = [
              {
                type = "markets";
                hide-header = true;
                markets = [
                  {
                    symbol = "VWCE";
                    name = "VWCE";
                  }

                  {
                    symbol = "BTC-USD";
                    name = "Bitcoin";
                  }
                ];
              }
            ];
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "calendar";
                  }
                  {
                    type = "weather";
                    location = "Porto, Portugal";
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
                ];
              }

              {
                size = "full";
                widgets = [
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services";
                    sites =
                      builtins.listToAttrs (
                        map mkSite [
                          "jellyfin"
                          "radarr"
                          "sonarr"
                        ]
                      )
                      // builtins.listToAttrs (
                        map mkSiteNoIcon [
                          "jellyseerr"
                          "prowlarr"
                          "cloud"
                          "sabnzbd"
                        ]
                      );
                  }
                ];
              }

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
                ];
              }
            ];
          }
        ];
      };
    };
}
