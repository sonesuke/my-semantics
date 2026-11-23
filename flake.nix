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

        # okq is not in nixpkgs; build the release from crates.io.
        okq = pkgs.rustPlatform.buildRustPackage rec {
          pname = "okq";
          version = "0.10.0";
          src = pkgs.fetchCrate {
            inherit pname version;
            hash = "sha256-eEji/gq7h2N/F/Ma8IJsduHUFq52zYJc43GrR3CEGnA=";
          };
          cargoHash = "sha256-A6UEayPbV96omv4Hqf7+ekVbwXLRrMr5J1QOwRfuWIU=";
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.zstd ];
          doCheck = false;
          meta = {
            description = "CLI to search and navigate Open Knowledge Format bundles";
            homepage = "https://github.com/mikevalstar/okq";
            license = pkgs.lib.licenses.asl20;
            mainProgram = "okq";
          };
        };
      in
      {
        packages.okq = okq;

        # okq validates and queries the OKF bundle in Knowledge/;
        # nixfmt, statix and deadnix format and lint the Nix files;
        # elan installs the Lean toolchain pinned in lean-toolchain.
        devShells.default = pkgs.mkShell {
          packages = [
            okq
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
