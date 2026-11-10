# nix-packages — app package definitions as a nix flake.
# Consumed by host-config flakes as a `nix-packages` input; the package
# files are plain callPackage derivations under packages/.

{
  description = "skattkammaren app packages (opencode, pi, vibe)";

  outputs = { self }: {
    # Nothing is built here eagerly; host flakes callPackage the files
    # directly:  pkgs.callPackage "${nix-packages}/packages/pi.nix" { }
  };
}
