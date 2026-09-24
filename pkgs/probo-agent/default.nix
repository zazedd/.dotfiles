{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "probo-agent";
  version = "0.7.1";

  src = fetchurl {
    url = "https://github.com/getprobo/probo/releases/download/probo-agent/v${finalAttrs.version}/probo-agent_${finalAttrs.version}_darwin.pkg";
    hash = "sha256-t2XAMbtVKWL746vIheS1gu5JJYb+/GwQnWu/2rF47Vk=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/probo-agent/probo-agent.pkg

    mkdir -p $out/bin
    cat > $out/bin/probo-agent <<'EOF'
    #!/bin/sh
    exec /Library/Probo/probo-agent "$@"
    EOF
    chmod +x $out/bin/probo-agent

    runHook postInstall
  '';

  meta = {
    description = "Desktop agent for collecting device posture evidence for Probo";
    homepage = "https://github.com/getprobo/probo";
    license = lib.licenses.mit;
    mainProgram = "probo-agent";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
