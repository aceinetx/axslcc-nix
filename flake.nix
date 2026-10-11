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

        runtimeLibs = with pkgs; [
          zlib
          gcc
          cmake
          pkg-config
          spirv-tools
          glslang
        ];
      in
      {
        packages = rec {
          axslcc-legacy = pkgs.stdenv.mkDerivation {
            name = "axslcc-legacy";

            src = pkgs.fetchgit {
              url = "https://github.com/axmolengine/axslcc-legacy";
              rev = "v3.6.0";
              sha256 = "sha256-tx0BZXVAOie3EOTdPdA0GMZ7EY6bl1CpqHXkf0CgE8U=";
            };

            nativeBuildInputs = [
              pkgs.cmake
              pkgs.gcc
              pkgs.pkg-config
              pkgs.ninja
              pkgs.python3
            ];

            buildInputs = runtimeLibs;

            patchPhase = ":";

            configurePhase = ''
              ls ${self}
              cp ${self}/glslang 3rdparty/glslang

              mkdir -p build
              cd build
              cmake .. -DCMAKE_BUILD_TYPE=Release
            '';

            buildPhase = ''
              ls
              sed -i "s/cmake_minimum_required(VERSION .*)/cmake_minimum_required(VERSION 3.10)/" $(find . -name "CMakeLists.txt")
              echo $(find . -name "CMakeLists.txt")

              make -j$(nproc)
            '';

            installPhase = ''
              mkdir -p $out/bin

              cp src/glslcc $out/bin/glslcc
              cp src/glslcc $out/bin/axslcc
            '';
          };

          axslcc = pkgs.stdenv.mkDerivation {
            name = "axslcc";

            src = pkgs.fetchgit {
              url = "https://github.com/axmolengine/axslcc";
              rev = "v3.99.2";
              sha256 = "sha256-RcbXYurgCrO6nd8VFf8iDc2vmtjcmbxWhWTl5oX/eaU=";
            };

            nativeBuildInputs = [
              pkgs.cmake
              pkgs.gcc
              pkgs.pkg-config
              pkgs.ninja
              pkgs.python3
            ];

            buildInputs = runtimeLibs;

            patchPhase = ":";

            configurePhase = ":";

            buildPhase = ''
              ls
              sed -i "s/cmake_minimum_required(VERSION .*)/cmake_minimum_required(VERSION 3.10)/" $(find . -name "CMakeLists.txt")
              echo $(find . -name "CMakeLists.txt")

              mkdir -p build
              cd build
              cmake .. -DCMAKE_BUILD_TYPE=Release
              make -j$(nproc)
            '';

            installPhase = ''
              mkdir -p $out/bin

              cp src/glslcc $out/bin/glslcc
              cp src/glslcc $out/bin/axslcc
            '';
          };

          default = axslcc-legacy;
        };
      }
    );
}
