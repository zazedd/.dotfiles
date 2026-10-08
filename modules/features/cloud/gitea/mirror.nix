{ inputs, ... }:
{
  flake.modules.nixos.cloud =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      giteaConfig = "${config.services.gitea.customDir}/conf/app.ini";
      gitea = lib.getExe config.services.gitea.package;
      runAsGitea = "${pkgs.util-linux}/bin/runuser -u ${config.services.gitea.user} --";
      mirrorUrl = "http://127.0.0.1:${toString config.registry.git-mirror.port}";
      mirrorDataDir = config.services.gitea-mirror.dataDir;
    in
    {
      imports = [ inputs.gitea-mirror.nixosModules.default ];

      sops.secrets = {
        github-token = { };
        gitea-bootstrap-password = { };
        gitea-repositories = { };
      };

      services.gitea-mirror = {
        enable = true;
        host = "127.0.0.1";
        port = config.registry.git-mirror.port;
        betterAuthUrl = "https://git-mirror.leoms.dev";
        betterAuthTrustedOrigins = "https://git-mirror.leoms.dev";
        environmentFile = "/run/gitea-mirror/config.env";
      };

      # Create the destination account and its API token, then build the
      # environment consumed by gitea-mirror.
      systemd.services.gitea-mirror-env = {
        description = "Provision credentials for gitea-mirror";
        requires = [ "gitea.service" ];
        after = [ "gitea.service" ];
        before = [ "gitea-mirror.service" ];
        unitConfig.RequiresMountsFor = [ "/data/cloud" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          set -euo pipefail
          install -d -m 0700 -o gitea-mirror -g gitea-mirror ${mirrorDataDir}
          install -d -m 0750 -o gitea-mirror -g gitea-mirror /run/gitea-mirror

          password="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.gitea-bootstrap-password.path})"

          if ! ${runAsGitea} ${gitea} --config ${giteaConfig} admin user list --admin \
              | ${pkgs.gnugrep}/bin/grep -qE '(^|[[:space:]])mirror([[:space:]]|$)'; then
            ${runAsGitea} ${gitea} --config ${giteaConfig} admin user create \
              --username mirror \
              --email mirror@leoms.dev \
              --password "$password" \
              --admin \
              --must-change-password=false
          fi

          tokenFile=${mirrorDataDir}/gitea-token
          if [ ! -s "$tokenFile" ]; then
            ${runAsGitea} ${gitea} --config ${giteaConfig} admin user generate-access-token \
              --username mirror --token-name gitea-mirror --scopes all --raw > "$tokenFile"
            chown gitea-mirror:gitea-mirror "$tokenFile"
            chmod 0400 "$tokenFile"
          fi

          umask 077
          {
            printf 'GITHUB_TOKEN=%s\n' "$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.github-token.path})"
            printf 'GITEA_TOKEN=%s\n' "$(${pkgs.coreutils}/bin/cat "$tokenFile")"
            cat <<'EOF'
          SOURCE_PROVIDER=github
          PUBLIC_REPOSITORIES=true
          PRIVATE_REPOSITORIES=false
          INCLUDE_ARCHIVED=true
          SKIP_FORKS=false
          MIRROR_STRATEGY=preserve
          DESTINATION_PROVIDER=gitea
          GITEA_URL=http://127.0.0.1:${toString config.registry.git.port}
          GITEA_EXTERNAL_URL=https://git.leoms.dev
          GITEA_USERNAME=mirror
          GITEA_MIRROR_INTERVAL=1h
          GITEA_CREATE_ORG=true
          GITEA_PRESERVE_VISIBILITY=true
          GITEA_LFS=true
          MIRROR_WIKI=true
          MIRROR_RELEASES=true
          MIRROR_ISSUES=true
          MIRROR_PULL_REQUESTS=true
          MIRROR_LABELS=true
          MIRROR_MILESTONES=true
          MIRROR_METADATA=true
          SCHEDULE_ENABLED=true
          SCHEDULE_INTERVAL=1h
          AUTO_IMPORT_REPOS=false
          AUTO_MIRROR_REPOS=true
          EOF
          } > /run/gitea-mirror/config.env
          chown gitea-mirror:gitea-mirror /run/gitea-mirror/config.env
          chmod 0400 /run/gitea-mirror/config.env
        '';
      };

      systemd.services.gitea-mirror = {
        requires = [ "gitea-mirror-env.service" ];
        after = [ "gitea-mirror-env.service" ];
      };

      # Better Auth needs an account before it can attach the environment
      # configuration. This only runs during the initial deployment.
      systemd.services.gitea-mirror-bootstrap = {
        description = "Create the initial gitea-mirror administrator";
        wants = [ "gitea-mirror.service" ];
        after = [ "gitea-mirror.service" ];
        wantedBy = [ "multi-user.target" ];
        path = [
          pkgs.curl
          pkgs.systemd
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          set -euo pipefail
          marker=${mirrorDataDir}/.admin-bootstrapped
          [ -e "$marker" ] && exit 0

          password="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.gitea-bootstrap-password.path})"
          for attempt in $(${pkgs.coreutils}/bin/seq 1 60); do
            if curl --fail --silent --show-error \
              -H 'Content-Type: application/json' \
              --data "{\"name\":\"mirror\",\"email\":\"mirror@leoms.dev\",\"password\":\"$password\"}" \
              ${mirrorUrl}/api/auth/sign-up/email >/dev/null; then
              touch "$marker"
              chown gitea-mirror:gitea-mirror "$marker"
              systemctl --no-block restart gitea-mirror.service
              exit 0
            fi
            sleep 2
          done
          echo "gitea-mirror did not become ready" >&2
          exit 1
        '';
      };

      # Reconcile the declarative owner/name list with gitea-mirror. Existing
      # entries are left alone; newly added entries are mirrored immediately.
      systemd.services.gitea-mirror-repositories = {
        description = "Reconcile declarative gitea-mirror repositories";
        requires = [
          "gitea-mirror.service"
          "gitea-mirror-bootstrap.service"
        ];
        after = [
          "gitea-mirror.service"
          "gitea-mirror-bootstrap.service"
        ];
        wantedBy = [ "multi-user.target" ];
        path = [
          pkgs.curl
          pkgs.jq
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          set -euo pipefail
          workdir=$(mktemp -d)
          trap 'rm -rf "$workdir"' EXIT
          cookieJar="$workdir/cookies"
          response="$workdir/response"
          password="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.gitea-bootstrap-password.path})"

          for attempt in $(${pkgs.coreutils}/bin/seq 1 60); do
            if curl --fail --silent --show-error \
              --cookie-jar "$cookieJar" \
              -H 'Content-Type: application/json' \
              --data "{\"email\":\"mirror@leoms.dev\",\"password\":\"$password\"}" \
              ${mirrorUrl}/api/auth/sign-in/email > /dev/null; then
              break
            fi
            [ "$attempt" -eq 60 ] && exit 1
            sleep 2
          done

          mirror_repository() {
            owner="$1"
            repository="$2"
            status=$(curl --silent --show-error \
              --cookie "$cookieJar" \
              -H 'Content-Type: application/json' \
              --data "{\"owner\":\"$owner\",\"repo\":\"$repository\"}" \
              --output "$response" \
              --write-out '%{http_code}' \
              ${mirrorUrl}/api/sync/repository)

            case "$status" in
              200)
                id=$(jq -er '.repository.id' "$response")
                curl --fail --silent --show-error \
                  --cookie "$cookieJar" \
                  -H 'Content-Type: application/json' \
                  --data "{\"repositoryIds\":[\"$id\"]}" \
                  ${mirrorUrl}/api/job/mirror-repo > /dev/null
                ;;
              409)
                ;;
              *)
                echo "Failed to add $owner/$repository (HTTP $status)" >&2
                cat "$response" >&2
                return 1
                ;;
            esac
          }

          while IFS=/ read -r owner repository extra; do
            [ -z "$owner$repository$extra" ] && continue
            if [ -z "$owner" ] || [ -z "$repository" ] || [ -n "$extra" ]; then
              echo "Invalid repository entry; expected owner/name" >&2
              exit 1
            fi
            mirror_repository "$owner" "$repository"
          done < ${config.sops.secrets.gitea-repositories.path}
        '';
      };
    };
}
