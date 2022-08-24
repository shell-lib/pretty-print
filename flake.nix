{
  description = "Pretty Print";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nonstdlib.url = "github:shell-lib/nonstdlib";
  };
  outputs = { self, nixpkgs, flake-utils, nonstdlib, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        package-name = "pretty-print";
        runtime-dependencies = [ 
          nonstdlib.defaultPackage.${system}
        ];
      in rec {
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.shellcheck
            pkgs.shfmt
          ];
        };

        defaultPackage = with import nixpkgs { inherit system; };
          stdenv.mkDerivation {
            name = package-name;
            src = self;
            buildInputs = runtime-dependencies;
            installPhase = ''
              mkdir -p $out/bin;
              install --target-directory $out/bin $name;
            '';
          };
      });
}
