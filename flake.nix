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
          pkgs.hello
        ];
      in rec {
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.shellcheck
            pkgs.shfmt
          ];
        };

        defaultPackage = pkgs.writeShellApplication {
          name = package-name;
          runtimeInputs = runtime-dependencies;
          text = (builtins.readFile ./${package-name});
        };
      });
}
