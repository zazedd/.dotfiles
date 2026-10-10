_: {
  flake.modules.nixos.server =
    { config, pkgs, ... }:
    {
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      fileSystems."/data/cloud" = {
        device = "/dev/disk/by-label/cloud";
        fsType = "btrfs";
        options = [
          "compress=zstd"
          "x-systemd.automount"
          "nofail"
        ];
        neededForBoot = false;
      };

      fileSystems."/backup" = {
        device = "/dev/disk/by-label/backup";
        fsType = "btrfs";
        options = [
          "compress=zstd"
          "x-systemd.automount"
          "nofail"
        ];
        neededForBoot = false;
      };

      fileSystems."/data/media" = {
        device = "/dev/disk/by-label/media";
        fsType = "ext4";
        options = [
          "nofail"
          "x-systemd.automount"
        ];
        neededForBoot = false;
      };

      fileSystems."/data/gaming" = {
        device = "/dev/disk/by-label/gaming";
        fsType = "ext4";
        options = [
          "nofail"
          "noatime"
        ];
        neededForBoot = false;
      };

      # systemd services relating to disks

      systemd.services.hd-idle = {
        description = "external HDD spin down daemon";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = ''
            ${pkgs.hd-idle}/bin/hd-idle \
              -i 0 \
              -a /dev/disk/by-label/cloud -i 600 \
              -a /dev/disk/by-label/backup -i 600 \
              -a /dev/disk/by-label/media -i 600
          '';
        };
        after = [
          "dev-disk-by\\x2dlabel-cloud.device"
          "dev-disk-by\\x2dlabel-backup.device"
          "dev-disk-by\\x2dlabel-media.device"
        ];
        wants = [
          "dev-disk-by\\x2dlabel-cloud.device"
          "dev-disk-by\\x2dlabel-backup.device"
          "dev-disk-by\\x2dlabel-media.device"
        ];
      };

      sops.secrets.restic-password = { };

      services.postgresqlBackup = {
        enable = true;
        backupAll = true;
        compression = "zstd";
        location = "/var/backup/databases/postgresql";
        startAt = [ ];
      };

      services.restic.backups = {
        cloud = {
          initialize = true;
          repository = "/backup/restic/cloud";
          passwordFile = config.sops.secrets.restic-password.path;
          paths = [
            "/data/cloud"
            "/var/backup/databases"
            "/var/lib/actual"
            "/var/lib/beszel-agent"
            "/var/lib/beszel-hub"
            "/var/lib/gitea"
          ];
          exclude = [ "/data/cloud/attic" ];
          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 4"
            "--keep-monthly 12"
            "--keep-yearly 3"
          ];
          timerConfig = {
            OnCalendar = "*-*-* 03:00:00";
            Persistent = true;
            RandomizedDelaySec = "30m";
          };
        };

        cloud-check = {
          repository = "/backup/restic/cloud";
          passwordFile = config.sops.secrets.restic-password.path;
          runCheck = true;
          checkOpts = [ "--read-data-subset=10%" ];
          timerConfig = {
            OnCalendar = "monthly";
            Persistent = true;
          };
        };
      };

      systemd.services.sqlite-backup = {
        description = "Consistent SQLite database backups";
        serviceConfig.Type = "oneshot";
        path = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.sqlite
        ];
        script = ''
          set -euo pipefail

          destination=/var/backup/databases/sqlite
          install -d -m 0700 "$destination/actual"

          backup_db() {
            local source="$1"
            local target="$2"
            if [[ -f "$source" ]]; then
              install -d -m 0700 "$(dirname "$target")"
              sqlite3 "$source" ".backup '$target'"
            fi
          }

          backup_db /var/lib/beszel-hub/pb_data/data.db "$destination/beszel.db"
          backup_db /var/lib/gitea/data/gitea.db "$destination/gitea.db"
          backup_db /data/cloud/documents/db.sqlite3 "$destination/paperless.db"

          while IFS= read -r -d "" database; do
            relative="''${database#/var/lib/actual/}"
            backup_db "$database" "$destination/actual/$relative"
          done < <(find /var/lib/actual -type f \( -name "*.db" -o -name "*.sqlite" \) -print0)
        '';
      };

      systemd.services = {
        restic-backups-cloud = {
          requires = [
            "postgresqlBackup.service"
            "sqlite-backup.service"
          ];
          after = [
            "postgresqlBackup.service"
            "sqlite-backup.service"
          ];
          unitConfig.RequiresMountsFor = [
            "/data/cloud"
            "/backup"
          ];
        };
        restic-backups-cloud-check.unitConfig.RequiresMountsFor = [ "/backup" ];
      };

      email-on-failure = {
        postgresqlBackup = true;
        sqlite-backup = true;
        restic-backups-cloud = true;
        restic-backups-cloud-check = true;
      };

      #systemd.services."backup-minecraft" = {
      #  enable = false;
      #  description = "rsync backup of /srv/minecraft/estupidos/backups to /backup/minecraft";
      #  serviceConfig = {
      #    Type = "oneshot";
      #    ExecStart = "${pkgs.rsync}/bin/rsync -a --delete /srv/minecraft/estupidos/backups/ /backup/minecraft/";
      #  };
      #};

      #systemd.timers."backup-minecraft" = {
      #  enable = false;
      #  description = "run backup-minecraft daily";
      #  wantedBy = [ "timers.target" ];
      #  timerConfig = {
      #    OnCalendar = "daily";
      #    Persistent = true;
      #  };
      #};

      swapDevices = [
        { device = "/dev/disk/by-label/swap"; }
        {
          device = "/var/lib/swapfile";
          size = 32 * 1024;
        }
      ];
    };
}
