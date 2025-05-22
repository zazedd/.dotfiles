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
          {{ $thumbURL := concat "${JELLYFIN_URL}/Items/" $thumbID "/Images/Primary?api_key=${JELLYFIN_KEY}" }}

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
