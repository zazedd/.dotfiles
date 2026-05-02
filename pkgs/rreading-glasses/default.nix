{ pkgs, lib, ... }:

pkgs.buildGoModule {
  pname = "rreading-glasses";
  version = "unstable-2026-05-02";

  go = pkgs.go;

  src = pkgs.fetchFromGitHub {
    owner = "blampe";
    repo = "rreading-glasses";
    rev = "a2939b625d91389d3f0a3e58cbc3bfa7ebb8390a";
    hash = "sha256-EQrHMD/el1sjo3bhW8pYal4BZfJLi5OM3myeO473PVY=";
  };

  # Hardcover variant (rghc); use cmd/rgg for Goodreads (not recommended for fresh installs)
  subPackages = [ "cmd/rghc" ];

  # Upstream go.sum is incomplete; proxy fetches the missing transitive deps.
  proxyVendor = true;
  vendorHash = "sha256-4HdqCWS7o1tSfDXfrm0UF5otHCi2NU5YwqeIy9T9ris=";
}
