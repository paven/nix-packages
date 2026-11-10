# OpenCode v2 — single static binary release from sst/anomalyco GitHub.
#
# Nixpkgs' opencode lags behind (and pins an old major), so we fetch the
# official release tarball directly and sideload the version we want.
# Bump the version by changing `version` and `hash` (nix will tell you the
# real hash on the first build failure).

{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  version ? "2.2.7",
  hash ? "sha256-iabO4ie1S8ARF5xSil5jF2AyRisaXiFyO2FoAc3cLKc=",
}:

stdenv.mkDerivation {
  pname = "opencode";
  inherit version;

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
    inherit hash;
  };

  # The tarball has no directories, just the binary — strip it into place.
  sourceRoot = ".";

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 opencode $out/bin/opencode
    runHook postInstall
  '';

  # The binary is a static musl-ish build; NixOS runs it as-is. We don't
  # patchelf — upstream's release binary expects standard glibc paths.
  meta = with lib; {
    description = "OpenCode AI coding agent (official prebuilt release)";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "opencode";
  };
}
