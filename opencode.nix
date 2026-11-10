# OpenCode v2 — official release binary, run inside an FHS bubble.
#
# The opencode binary is a Bun single-file standalone. patchelf breaks its
# embedded-payload resolution (the binary then falls back to plain bun) and
# NixOS has no /lib64/ld-linux — so we keep the pristine binary and give it a
# normal Linux userland via buildFHSEnv (same pattern as the vibe agent).
#
# Binary source: the platform package the official installer
# (opencode.ai/install) also downloads — @opencode/cli-linux-x64 from npm.
#
# Bump `version` + `hash` together (nix prints the correct hash on mismatch).

{
  lib,
  stdenv,
  buildFHSEnv,
  fetchurl,
  version ? "2.2.7",
}:

let
  # The npm platform tarball contains package/bin/opencode.
  platformPkg = stdenv.mkDerivation {
    pname = "opencode-bin";
    inherit version;
    src = fetchurl {
      url = "https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
      hash = "sha256-1lk1Rk+T8HkTYz+XfLmXI69k7v9q56gicizom+2r3UU=";
    };
    sourceRoot = ".";
    dontBuild = true;
    dontConfigure = true;
    # Critical: default fixup (strip + patchelf shlib handling) corrupts the
    # bun single-file payload — the binary then degrades to plain bun.
    dontFixup = true;
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 package/bin/opencode $out/libexec/opencode
      runHook postInstall
    '';
    meta = with lib; {
      platforms = [ "x86_64-linux" ];
    };
  };
in
buildFHSEnv {
  pname = "opencode";
  inherit version;
  targetPkgs = p: [ p.glibc ];
  # Unset & clean env so the binary sees a standard Linux layout. The FHS
  # bubble supplies /lib64/ld-linux via the glibc mount.
  runScript = "${platformPkg}/libexec/opencode";
  # Callers that must run the bare binary inside their OWN FHS bubble
  # (e.g. the openchamber service) use this instead of the wrapper.
  passthru.binary = platformPkg;
  passthru.binaryPath = "${platformPkg}/libexec/opencode";
  meta = with lib; {
    description = "OpenCode AI coding agent (official prebuilt release, FHS-wrapped)";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "opencode";
  };
}
