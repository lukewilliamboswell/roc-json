{
  description = "json package devShell flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # to easily make configs for multiple architectures
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };

        linuxInputs = with pkgs;
          lib.optionals stdenv.isLinux [
          ];

        darwinInputs = with pkgs;
          lib.optionals stdenv.isDarwin
          (with pkgs.darwin.apple_sdk.frameworks; [
          ]);

        sharedInputs = (with pkgs; [
          expect
        ]);
      in {

        devShell = pkgs.mkShell {
          buildInputs = sharedInputs ++ darwinInputs ++ linuxInputs;
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
