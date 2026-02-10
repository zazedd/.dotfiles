{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,

  libgcc,
  libcxx,
  libssh,
  llvmPackages,
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
  pname = "teamspeak6-server";
  version = "6.0.0-beta8";

  src = fetchurl {
    url = "https://github.com/teamspeak/teamspeak6-server/releases/download/v${
      lib.replaceString "-" "%2F" version
    }/teamspeak-server_linux_amd64-v${version}.tar.bz2";
    hash = "sha256-U9jazezXFGcW95iu20Ktc64E1ihXSE4CiQx3jkgDERc=";
  };

  sourceRoot = "./teamspeak-server_linux_amd64";

  propagatedBuildInputs = [
    libgcc
    libcxx
    libssh
    llvmPackages.libunwind
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/teamspeak6-server

    rm libatomic.so.1 libc++.so.1 libssh.so.4 libunwind.so.1
    cp -a * $out/share/teamspeak6-server

    makeWrapper $out/share/teamspeak6-server/tsserver $out/bin/tsserver \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libgcc
          libcxx
          libssh
          llvmPackages.libunwind
        ]
      }"

    runHook postInstall
  '';

  meta = {
    description = "TeamSpeak voice communication server (beta version)";
    homepage = "https://teamspeak.com/";
    # license = lib.licenses.teamspeak;
    mainProgram = "tsserver";
    platforms = [ "x86_64-linux" ];
  };
})

