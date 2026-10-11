{
  description = "Axmol Shader Compiler CLI tool (axslcc)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = rec {
          axslcc-legacy = pkgs.stdenv.mkDerivation {
            name = "axslcc-legacy";

            src = pkgs.fetchurl {
              url = "https://github.com/axmolengine/axslcc-legacy/releases/download/v3.6.0/axslcc-3.6.0-linux-x64.tar.gz";
              sha256 = "sha256-4FuupZMSDEFUd6e5xIp8t7vBJGs4gJo1CLsM/wzE/Mc=";
            };

            sourceRoot = ".";

            buildPhase = ''
              mkdir -p $out/bin

              cp axslcc $out/bin
              ln -s $out/bin/axslcc $out/bin/glslcc
            '';
          };

          axslcc = pkgs.stdenv.mkDerivation {
            name = "axslcc";

            src = pkgs.fetchurl {
              url = "https://github.com/axmolengine/axslcc/releases/download/v3.99.2/axslcc-3.99.2-linux-x64.tar.gz";
              sha256 = "sha256-I2r/CZm56bCZFjN4YUo0HWuL/iMbA56HbmvMhLAFGjA=";
            };

            sourceRoot = ".";

            buildInputs = with pkgs; [
              makeWrapper
            ];

            buildPhase = ''
              mkdir -p $out/bin
              mkdir -p $out/lib

              cp axslcc-3.99.2-linux-x64/bin/* .

              cp axslcc $out/bin/axslcc-real
              cp libdxcompiler.so $out/lib

              makeWrapper $out/bin/axslcc-real $out/bin/axslcc --set LD_LIBRARY_PATH "$out/lib"
            '';
          };

          default = axslcc;
        };
      }
    );
}
