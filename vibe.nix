# mistral-vibe package — built at the flake level (see flake.nix: the
# pyproject-nix/uv2nix overlay must be evaluated outside the module system's
# pkgs scope, or its fixed-point loop recurses infinitely).
#
# Update flow: bump `mistral-vibe==X.Y.Z` in packages/vibe/pyproject.toml,
# regenerate uv.lock, commit, rebuild. No $HOME mutation anywhere.
#
# This module just installs the prebuilt package:

{ lib, pkgs, agent-pkgs, ... }:

{
  environment.systemPackages = [ agent-pkgs.vibe ];
}
