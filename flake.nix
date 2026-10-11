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
      rec {
        axslcc-legacy-versions = {
          "3.6.0" = {
            url = "https://github.com/axmolengine/axslcc-legacy/releases/download/v3.6.0/axslcc-3.6.0-linux-x64.tar.gz";
            hash = "sha256-4FuupZMSDEFUd6e5xIp8t7vBJGs4gJo1CLsM/wzE/Mc=";
          };
          "1.9.5" = {
            url = "https://github.com/axmolengine/axslcc-legacy/releases/download/v1.9.5/glslcc-1.9.5-linux.tar.gz";
            hash = "sha256-46pT1FMytCdzsbqmaGxpvvI30J5wJAQS6mlLSXn6DOw=";
          };
        };
        packages = {
          mkAxslccLegacy =
            {
              version ? "1.9.5",
            }:
            pkgs.stdenv.mkDerivation {
              name = "axslcc-legacy";

              src = pkgs.fetchurl {
                url = axslcc-legacy-versions.${version}.url;
                sha256 = axslcc-legacy-versions.${version}.hash;
              };

              sourceRoot = ".";

              buildPhase = ''
                mkdir -p $out/bin

                if [ -e "axslcc" ]; then
                    cp axslcc $out/bin
                    ln -s $out/bin/axslcc $out/bin/glslcc
                elif [ -e "glslcc" ]; then
                    cp glslcc $out/bin
                    ln -s $out/bin/glslcc $out/bin/axslcc
                else
                    echo "No axslcc or glslcc"
                    exit 1
                fi
              '';
            };

          mkAxslcc =
            { }:
            pkgs.stdenv.mkDerivation {
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
        };
      }
    );
}
