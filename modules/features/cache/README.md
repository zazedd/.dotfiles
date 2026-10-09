# Attic cache bootstrap

`https://cache.leoms.dev`
After deploying the server module for the first time, initialize the cache from a machine connected to the tailnet:

```sh
bootstrap_token="$(atticd-atticadm make-token \
  --sub bootstrap \
  --validity 1h \
  --create-cache dotfiles \
  --configure-cache dotfiles \
  --configure-cache-retention dotfiles \
  --pull dotfiles \
  --push dotfiles)"

attic login home https://cache.leoms.dev "$bootstrap_token"
attic cache create home:dotfiles --public
attic cache configure home:dotfiles --retention-period "1 week"
attic cache info home:dotfiles
```

Copy the public key printed by the final command into the shared Nix
`trusted-public-keys`, and add `https://cache.leoms.dev/dotfiles` to the shared
`substituters`. This requires a second rebuild because Attic generates the cache
signing key when the cache is created.

Create the narrower token used by CI:

```sh
atticd-atticadm make-token \
  --sub github-actions \
  --validity 5y \
  --pull dotfiles \
  --push dotfiles
```

Configure the GitHub repository with:

- Secret `ATTIC_TOKEN`: output of the command above.
- Secrets `TS_OAUTH_CLIENT_ID` and `TS_OAUTH_SECRET`: a Tailscale OAuth client with `auth_keys` write scope and permission to create `tag:ci` nodes.
- Variable `ATTIC_ENABLED`: `true` after Attic and the cache are ready.

The tailnet policy must allow `tag:ci` to reach the sv on TCP port 443. CI nodes are ephemeral and are removed when each job finishes.
