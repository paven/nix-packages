# nix-packages

Shared Nix package definitions for the skattkammaren home server (see
[skattkammaren flake](../..)) and any other machine that needs them.

Packages are consumed by adding this repo as a flake input and calling the
derivations with `callPackage`. Example:

```nix
# flake.nix
{
  inputs.nix-packages.url = "github:YOUR-USER/nix-packages";
}

# usage
pkgs.callPackage (inputs.nix-packages + "/packages/opencode.nix") { }
```

## Packages

| Package | Purpose |
|---|---|
| `opencode.nix` | OpenCode v2 CLI (prebuilt official release tarball) |
| `pi.nix` | Pi coding agent (@earendil-works/pi-coding-agent) |
| `vibe.nix` | Mistral Vibe agent (uv2nix build from uv.lock) |

## Version bumps

OpenCode and Pi versions are pinned in the derivations. Bump by editing the
`version` (and `hash` for opencode) fields — the build will fail loudly if
the hash no longer matches.
