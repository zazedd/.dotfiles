{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  fetchYarnDeps,
  yarn,
  fixup-yarn-lock,
  nodejs,
  prefetch-yarn-deps,
  sqlite,
  libmediainfo,
  ffmpeg,
}:

let
  version = "0.9.965";
  src = fetchFromGitHub {
    owner = "Chaptarr";
    repo = "chaptarr";
    tag = "v${version}";
    hash = "sha256-4/739wVufOwVobNlOUNFz5FNVfDj4p9SqLtD1LW0aZY=";
  };
  rid = dotnetCorePackages.systemToDotnetRid stdenvNoCC.hostPlatform.system;
in
buildDotnetModule {
  pname = "chaptarr";
  inherit version src;

  strictDeps = true;

  postPatch = ''
    mv src/NuGet.config NuGet.Config
    substituteInPlace frontend/build/webpack.config.js \
      --replace-fail "moduleIds: 'deterministic'," \
        "moduleIds: 'deterministic', minimizer: [new TerserPlugin({ parallel: false })]," \
      --replace-fail 'cacheBuster: Date.now()' 'cacheBuster: "${version}"'
  '';

  nativeBuildInputs = [
    nodejs
    yarn
    prefetch-yarn-deps
    fixup-yarn-lock
  ];

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-82ITzb6WkWtSMcBv1PRjrf0z8VA6lza7zO5ywxxkTG8=";
  };

  postConfigure = ''
    yarn config --offline set yarn-offline-mirror "$yarnOfflineCache"
    fixup-yarn-lock yarn.lock
    yarn install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
    patchShebangs --build node_modules
  '';

  postBuild = ''
    yarn --offline run build
  '';

  postInstall = ''
    cp -a _output/UI "$out/lib/chaptarr/UI"
  '';

  nugetDeps = ./deps.json;
  runtimeDeps = [
    sqlite
    libmediainfo
  ];

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;

  executables = [ "Chaptarr" ];
  projectFile = [ "src/NzbDrone.Console/Chaptarr.Console.csproj" ];

  dotnetFlags = [
    "--property:TargetFramework=net10.0"
    "--property:EnableAnalyzers=false"
    "--property:SentryUploadSymbols=false"
    "--property:AssemblyVersion=${version}.0"
    "--property:AssemblyFileVersion=${version}.0"
    "--property:AssemblyInformationalVersion=${version}"
    "--property:AssemblyConfiguration=release"
    "--property:RuntimeIdentifier=${rid}"
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ ffmpeg ])
  ];

  meta = {
    description = "Book collection manager for audiobooks and eBooks";
    homepage = "https://github.com/Chaptarr/chaptarr";
    changelog = "https://github.com/Chaptarr/chaptarr/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "Chaptarr";
    platforms = lib.platforms.linux;
  };
}
