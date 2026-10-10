{ lib, ... }:
let
  libraryDir = "/data/media/books/calibre";
in
{
  flake.modules.nixos.mediaserver =
    { config, pkgs, ... }:
    let
      chaptarrToCalibre = pkgs.writeShellApplication {
        name = "chaptarr-to-calibre";
        runtimeInputs = [
          pkgs.calibre
          pkgs.util-linux
        ];
        text = ''
          log() {
            logger --tag chaptarr-to-calibre -- "$*"
            printf 'chaptarr-to-calibre: %s\n' "$*" >&2
          }

          # .NET's StringDictionary normalizes Chaptarr's environment-variable
          # names to lowercase before starting the script.
          event="''${chaptarr_eventtype:-}"
          added_paths="''${chaptarr_addedbookpaths:-}"
          if [[ "$event" == "Test" ]]; then
            log "Chaptarr connection test succeeded"
            exit 0
          fi
          if [[ "$event" != "Download" ]]; then
            log "Ignoring event: ''${event:-<unset>}"
            exit 0
          fi
          if [[ -z "$added_paths" ]]; then
            log "Download event did not contain chaptarr_addedbookpaths"
            exit 1
          fi

          export CALIBRE_CONFIG_DIRECTORY="''${TMPDIR:-/tmp}/calibre-config"
          mkdir -p "$CALIBRE_CONFIG_DIRECTORY"

          IFS='|' read -r -a paths <<< "$added_paths"
          imported=0
          for path in "''${paths[@]}"; do
            case "''${path,,}" in
              *.azw|*.azw3|*.cbz|*.epub|*.fb2|*.kepub|*.lit|*.lrf|*.mobi|*.pdf)
                if [[ ! -f "$path" ]]; then
                  log "Imported path does not exist: $path"
                  exit 1
                fi

                flock --wait 120 9
                log "Importing: $path"
                calibredb add \
                  --with-library ${lib.escapeShellArg libraryDir} \
                  --automerge overwrite \
                  "$path"
                imported=$((imported + 1))
                ;;
              *) log "Skipping non-eBook path: $path" ;;
            esac
          done 9>/tmp/chaptarr-to-calibre.lock
          log "Finished; imported $imported eBook file(s)"
        '';
      };
    in
    {
      environment.systemPackages = [
        pkgs.calibre
        chaptarrToCalibre
      ];

      systemd.tmpfiles.settings."10-calibre".${libraryDir}.d = {
        user = "media";
        group = "media";
        mode = "0775";
      };

      systemd.services.calibre-library-init = {
        description = "Initialize the Calibre library";
        before = [ "calibre-web.service" ];
        requiredBy = [ "calibre-web.service" ];
        unitConfig.RequiresMountsFor = [ libraryDir ];
        serviceConfig = {
          Type = "oneshot";
          User = "media";
          Group = "media";
          RemainAfterExit = true;
        };
        script = ''
          if [[ ! -e ${lib.escapeShellArg "${libraryDir}/metadata.db"} ]]; then
            output="$(${lib.getExe' pkgs.calibre "calibredb"} add \
              --with-library ${lib.escapeShellArg libraryDir} \
              --empty \
              --title '.calibre-library-initializer' \
              --authors 'System')"
            book_id="$(printf '%s\n' "$output" | ${lib.getExe pkgs.gnugrep} -oE '[0-9]+$' | tail -n1)"
            if [[ -n "$book_id" ]]; then
              ${lib.getExe' pkgs.calibre "calibredb"} remove \
                --with-library ${lib.escapeShellArg libraryDir} \
                "$book_id"
            fi
          fi
        '';
      };

      services.calibre-web = {
        enable = true;
        user = "media";
        group = "media";
        dataDir = "/var/lib/calibre-web";
        openFirewall = false;
        listen = {
          ip = "127.0.0.1";
          port = config.registry.calibre.port;
        };
        options = {
          calibreLibrary = libraryDir;
          enableBookUploading = true;
          enableBookConversion = true;
          enableKepubify = true;
        };
      };

      systemd.services.calibre-web.unitConfig.RequiresMountsFor = [ libraryDir ];
    };

  flake.modules.nixos.reverse-proxy = {
    registry.calibre = {
      port = 8083;
      aliases = [ "library" ];
    };
  };
}
