{
  stdenv,
  lib,
  gleam,
  bun,
  erlang,
  beamPackages,
  tailwindcss_4,
  ...
}:
let
  mkGleamDeps =
    name: src: hash:
    stdenv.mkDerivation {
      name = "${name}-deps";

      nativeBuildInputs = [
        gleam
        bun
      ];

      src = src;

      buildPhase = ''
        runHook preBuild

        mkdir fake_home
        HOME=fake_home

        gleam deps download

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        awk 'NR == 1; NR > 1 {print $0 | "sort -n"}' build/packages/packages.toml > packages_sorted.toml
        cp packages_sorted.toml build/packages/packages.toml

        mkdir $out
        cp -r build/packages/** $out

        rm $out/gleam.lock

        runHook postInstall
      '';

      outputHashMode = "recursive";
      outputHashAlgo = if hash == "" then "sha256" else null;
      outputHash = hash;
    };
in
stdenv.mkDerivation (finalAttrs: {
  name = "bagofholding";

  src = lib.cleanSource ./.;

  gleamDeps = mkGleamDeps finalAttrs.name finalAttrs.src finalAttrs.gleamDepsHash;
  gleamDepsHash = "sha256-F4huGnLmbEbU9MHc8u4yr+UavCt0KsTjilm/6wBP9yI=";

  nativeBuildInputs = [
    finalAttrs.gleamDeps
    gleam
    erlang
    beamPackages.rebar3
    bun
    tailwindcss_4
  ];

  buildPhase = ''
    mkdir -p build/packages
    cp -r ${finalAttrs.gleamDeps}/** build/packages
    chmod -R u+w build/packages
    gleam run -m lustre/dev build --minify --outdir=dist
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    gleam test

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r dist/** $out

    runHook postInstall
  '';
})
