{
  pkgs,
  JVM_OPTS,
  ...
}:

with pkgs;

stdenv.mkDerivation rec {
  pname = "purpur";
  version = "1.21.4r2394";

  src = fetchurl {
    url = "https://api.purpurmc.org/v2/purpur/${
      builtins.replaceStrings [ "r" ] [ "/" ] version
    }/download";
    sha256 = "sha256-v0moMVG1SKDyEzWFfGl/G+b3raT2gSQ2+X4v9x3x6aU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp -v $src $out/lib/minecraft/server.jar

    makeWrapper ${jdk}/bin/java $out/bin/minecraft-server \
      --add-flags "${JVM_OPTS}" \
      --add-flags "-jar $out/lib/minecraft/server.jar nogui"
  '';

  dontUnpack = true;

  passthru = {
    # If you plan on running paper without internet, be sure to link this jar
    # to `cache/mojang_{version}.jar`.
    vanillaJar = "${minecraft-server}/lib/minecraft/server.jar";
  };

  meta = with lib; {
    description = "Drop-in replacement for Minecraft Paper servers";
    longDescription = ''
      Purpur is a drop-in replacement for Minecraft Paper servers designed for configurability, new fun and exciting
      gameplay features, and performance built on top of Airplane.
    '';
    homepage = "https://purpurmc.org/";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ joelkoen ];
    mainProgram = "minecraft-server";
  };
}
