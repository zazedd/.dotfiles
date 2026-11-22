#!/usr/bin/env bash
set -euo pipefail

nix run nixpkgs#attic-client -- login home https://cache.leoms.dev "$ATTIC_TOKEN"

for delay in 0 10 30; do
  sleep "$delay"
  if nix run nixpkgs#attic-client -- push --jobs 1 home:dotfiles "$@"; then
    exit 0
  fi
done

echo '::warning title=Attic cache upload failed::The build passed, but Attic rejected the upload after three attempts. Check the atticd service logs.'
exit 1
