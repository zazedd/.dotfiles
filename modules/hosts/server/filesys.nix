{
  flake.modules.nixos.server =
    { pkgs, ... }:
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
      };

      systemd.services."backup-cloud" = {
        description = "rsync backup of /data/cloud to /backup/cloud";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.rsync}/bin/rsync -a --delete /data/cloud/ /backup/cloud/";
        };
      };

      systemd.timers."backup-cloud" = {
        description = "run backup-cloud daily";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };

      systemd.services."backup-minecraft" = {
        enable = false;
        description = "rsync backup of /srv/minecraft/estupidos/backups to /backup/minecraft";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.rsync}/bin/rsync -a --delete /srv/minecraft/estupidos/backups/ /backup/minecraft/";
        };
      };

      systemd.timers."backup-minecraft" = {
        enable = false;
        description = "run backup-minecraft daily";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };

      swapDevices = [
        { device = "/dev/disk/by-label/swap"; }
      ];

    };
}
