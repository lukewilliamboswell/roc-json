{
  description = "json package devShell flake";

  inputs = {

    # TODO restore when https://github.com/roc-lang/roc/pull/7463 lands in main
    roc.url = "github:smores56/roc?ref=auto-snake-case";

    nixpkgs.follows = "roc/nixpkgs";

    # to easily make configs for multiple architectures
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, roc }:
    let supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        rocPkgs = roc.packages.${system};

        linuxInputs = with pkgs;
          lib.optionals stdenv.isLinux [
          ];

        darwinInputs = with pkgs;
          lib.optionals stdenv.isDarwin
          (with pkgs.darwin.apple_sdk.frameworks; [
            pkgs.libiconv
          ]);

        sharedInputs = (with pkgs; [
          expect
          rocPkgs.cli
          simple-http-server
        ]);
      in {

        devShell = pkgs.mkShell {
          buildInputs = sharedInputs ++ darwinInputs ++ linuxInputs;
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
