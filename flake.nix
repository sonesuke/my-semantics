{
  description = "my-semantics: software development knowledge formalized in Lean 4";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Node.js runs prettier and markdownlint-cli2 (see package.json);
        # nixfmt, statix and deadnix format and lint the Nix files;
        # elan installs the Lean toolchain pinned in lean-toolchain.
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nodejs
            pkgs.nixfmt
            pkgs.statix
            pkgs.deadnix
            pkgs.elan
          ];
        };

        formatter = pkgs.nixfmt;
      }
    );
}
