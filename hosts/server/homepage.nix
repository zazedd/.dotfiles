{
  config,
  domain,
  ...
}:
let
  ports = import ./ports.nix;
in
{

  sops.secrets."glance-env" = { };
  systemd.services.glance.serviceConfig.EnvironmentFile = config.sops.secrets."glance-env".path;

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
                    template = ''
                      {{/* USER VARIABLES BEGIN */}}

                      {{/* Set to true if using the widget in a small column */}}
                      {{ $isSmallColumn := false }}

                      {{/* Set to true to use a short hand display of Series information */}}
                      {{ $isCompact := true }}

                      {{/* Set to true to show thumbnails */}}
                      {{ $showThumbnail := true }}

                      {{/* Depends on $showThumbnail */}}
                      {{/* Set to "square" to have an aspect ratio of 1 */}}
                      {{/* Set to "portrait" to have an aspect ratio of 3/4 */}}
                      {{/* Set to "landscape" to have an aspect ratio of 4/3 */}}
                      {{/* Set to "" to have the original aspect ratio */}}
                      {{ $thumbAspectRatio := "original" }}

                      {{/* Set to true to display user name */}}
                      {{ $showUser := true }}

                      {{/* Set to true to get absolute time format instead of relatie format */}}
                      {{ $timeAbsolute := false }}

                      {{/* USER VARIABLES END */}}

                      {{ $user := (.Subrequest "user").JSON.String "Name" }}

                      {{ if eq .Response.StatusCode 200 }}
                        {{ $history := .JSON.Array "Items" }}

                        {{ if eq (len $history) 0 }}
                          <p>stop what you are doing and go watch something !</p>
                        {{ else }}
                          <div class="carousel-container show-right-cutoff">
                            <div class="cards-horizontal carousel-items-container">
                              {{ range $n, $item := $history }}
                                {{/* WIDGET VARIABLES BEGIN */}}

                                {{ $mediaType := $item.String "Type" }}

                                {{ $isMovie := eq $mediaType "Movie" }}
                                {{ $isShows := eq $mediaType "Episode" }}
                                {{ $isMusic := eq $mediaType "Audio" }}

                                {{ $movieTitle := $item.String "Name" }}
                                {{ $showTitle := $item.String "SeriesName" }}
                                {{ $showSeason := $item.String "ParentIndexNumber" }}
                                {{ $showEpisode := $item.String "IndexNumber" }}
                                {{ $episodeTitle := $item.String "Name" }}
                                {{ $artist := $item.String "AlbumArtist" }}
                                {{ $albumTitle := $item.String "Album" }}
                                {{ $songTitle := $item.String "Name" }}
                                {{ $default := $item.String "Name" }}

                                {{ $thumbID := $item.String "Id" }}
                                {{ if $isShows }}
                                  {{ $thumbID = $item.String "SeasonId" }}
                                {{ end }}
                                {{ $thumbURL := concat "$${JELLYFIN_URL}/Items/" $thumbID "/Images/Primary?api_key=$${JELLYFIN_KEY}" }}

                                {{ $playedAt := $item.String "UserData.LastPlayedDate" | parseRelativeTime "rfc3339" }}
                                {{ if $timeAbsolute }}
                                  {{ $t := $item.String "UserData.LastPlayedDate" | parseTime "rfc3339" }}
                                  {{ $playedAt = $t.Format "Jan 02 15:04" }}
                                {{ end }}

                                {{/* WIDGET VARIABLES END */}}

                                {{/* WIDGET TEMPLATE BEGIN */}}

                                <div class="card widget-content-frame" >
                                  {{ if $showThumbnail }}
                                    <img
                                      src="{{ $thumbURL }}"
                                      alt="{{ $default }} thumbnail"
                                      loading="lazy"
                                      class="shrink-0"
                                      style="object-fit: cover;
                                        {{ if eq $thumbAspectRatio "square" }}
                                          aspect-ratio: 1;
                                        {{ else if eq $thumbAspectRatio "portrait" }}
                                          aspect-ratio: 3/4;
                                        {{ else if eq $thumbAspectRatio "landscape" }}
                                          aspect-ratio: 4/3;
                                        {{ else }}
                                          aspect-ratio: initial;
                                        {{ end }}
                                        border-radius: var(--border-radius) var(--border-radius) 0 0;"
                                    />
                                  {{ end }}
                                  <div class="grow padding-inline-widget margin-top-10 margin-bottom-10 {{ if $isSmallColumn -}}text-center{{- end }}" >
                                    <ul
                                      class="
                                        flex
                                        flex-column
                                        justify-evenly
                                        margin-bottom-3
                                        {{ if $isSmallColumn -}}size-h6{{- end }}
                                      "
                                      style="height: 100%;"
                                    >
                                      {{ if $isCompact }}
                                        <ul class="list-horizontal-text flex-nowrap">
                                          <li class="color-primary text-truncate">{{ $user }}</li>
                                          {{ if not $timeAbsolute }}
                                            <li class="shrink-0"><span {{ $playedAt }}></span></li>
                                          {{ end }}
                                        </ul>
                                        {{ if $timeAbsolute }}
                                          <li>{{ $playedAt }}</li>
                                        {{ end }}
                                      {{ else }}
                                        {{ if $showUser }}
                                          <li class="color-primary text-truncate">{{ $user }}</li>
                                        {{ end }}

                                        <li class="color-base text-truncate">
                                          {{ if $timeAbsolute }}
                                            <span>{{ $playedAt }}</span>
                                          {{ else }}
                                            <span {{ $playedAt }}></span>
                                            <span> ago</span>
                                          {{ end }}
                                        </li>
                                      {{ end }}
                                      {{ if $isMovie }}
                                        <li {{ if $isCompact -}}class="text-truncate"{{- end }}>{{ $movieTitle }}</li>
                                      {{ else if $isShows }}
                                        {{ if $isCompact }}
                                          <ul class="list-horizontal-text flex-nowrap">
                                            <li>{{ concat "S" $showSeason "E" $showEpisode }}</li>
                                            <li class="text-truncate">{{ $showTitle }}</li>
                                          </ul>
                                        {{ else }}
                                          <li class="text-truncate" >{{ $showTitle }}</li>
                                          {{ if $isSmallColumn }}
                                            <li>{{ concat "S" $showSeason "E" $showEpisode }}</li>
                                          {{ else }}
                                            <li class="text-truncate" >{{ concat "Season " $showSeason " Episode " $showEpisode }}</li>
                                          {{ end }}
                                        {{ end }}
                                        <li class="text-truncate" >{{ $episodeTitle }}</li>
                                      {{ else if $isMusic }}
                                        {{ if $isCompact }}
                                          <li class="text-truncate">{{ $artist }}</li>
                                        {{ else }}
                                          <li class="text-truncate">{{ $artist }}</li>
                                          <li class="text-truncate">{{ $albumTitle }}</li>
                                        {{ end }}
                                        <li class="text-truncate">{{ $songTitle }}</li>
                                      {{ else }}
                                        <li class="text-truncate">{{ $default }}</li>
                                      {{ end }}
                                    </ul>
                                  </div>
                                </div>

                                {{/* WIDGET TEMPLATE END */}}

                              {{ end }}
                            </div>
                          </div>
                        {{ end }}
                      {{ else }}
                        <p>Failed to fetch Jellyfin history</p>
                      {{ end }}
                    '';
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
