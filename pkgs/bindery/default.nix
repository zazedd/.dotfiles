{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
}:

let
  version = "1.40.1";

  src = fetchFromGitHub {
    owner = "vavallee";
    repo = "bindery";
    tag = "v${version}";
    hash = "sha256-jXudSb7K+KLExzhvmyh6oJNl49yRxc40Y8fzn84Ps5I=";
  };

  web = buildNpmPackage {
    pname = "bindery-web";
    inherit version;
    src = "${src}/web";

    npmDepsHash = "sha256-kurJZI2mBx4pZ9z5m4ZtwKROr/Kou2Z6gIO5c4VTPrk=";

    postPatch = ''
      mkdir -p ../internal/textutil/testdata
      cp ${src}/internal/textutil/testdata/search_fixtures.json ../internal/textutil/testdata/
    '';

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };
in
buildGoModule {
  pname = "bindery";
  inherit version src;

  vendorHash = "sha256-+r/IBdisnJirHbifrO71TSUn1PAvRJBJZdGFlXUwn8Y=";

  preBuild = ''
    rm -rf internal/webui/dist
    cp -r ${web} internal/webui/dist
  '';

  subPackages = [ "cmd/bindery" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  env.CGO_ENABLED = 0;

  meta = {
    description = "Automated ebook and audiobook manager for Usenet and torrents";
    homepage = "https://github.com/vavallee/bindery";
    changelog = "https://github.com/vavallee/bindery/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "bindery";
    platforms = lib.platforms.linux;
  };
}
