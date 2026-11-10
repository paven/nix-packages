# Pi coding agent — npm package wrapped as a nix derivation.
#
# src is the npm tarball, which ships PREBUILT (dist/ is in the tarball),
# so no monorepo build chain is needed — only the dependency tree.
#
# Lock story: the tarball has no package-lock.json, and its package.json
# trips an npm-arborist peer bug in lockfile generation (`.overrides` +
# vitest peers). We commit a pre-generated lock (pi/package-lock.json).
#
# Update flow: bump version + tarball hash, regenerate package-lock.json
# (extract tarball, jq-patch package.json, npm install --package-lock-only),
# commit, rebuild.

{
  lib,
  pkgs,
  version ? "1.5.0",
}:

pkgs.buildNpmPackage {
  pname = "pi-coding-agent";
  inherit version;
  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-W/tmhIpMS4HGN86NITa+AZRbcKrI6FVrCRywIkGzhd8=";
  };
  dontNpmBuild = true; # tarball ships prebuilt dist/
  postPatch = ''
    # mirror the jq patch used when package-lock.json was generated
    ${pkgs.nodejs_22}/bin/node -e '
      const fs = require("fs");
      const pj = JSON.parse(fs.readFileSync("package.json", "utf8"));
      delete pj.devDependencies; delete pj.overrides;
      fs.writeFileSync("package.json", JSON.stringify(pj, null, "\t"));
    '
    cp ${./pi/package-lock.json} ./package-lock.json
  '';
  # pinned npm tree hash — regenerate on version bump (build prints it)
  npmDepsHash = "sha256-D9Rs6pL9/Hy0/nLMO75Kq2k/+scAw7kG/3q3d7qEYV4=";
}
