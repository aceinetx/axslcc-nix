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
          axslcc-legacy = pkgs.stdenv.mkDerivation rec {
            name = "axslcc-legacy";

            src = pkgs.fetchgit {
              url = "https://github.com/axmolengine/axslcc-legacy";
              tag = "v3.6.0";
              sha256 = "sha256-tx0BZXVAOie3EOTdPdA0GMZ7EY6bl1CpqHXkf0CgE8U=";
            };

            glslang-repo = pkgs.fetchgit {
              url = "https://github.com/KhronosGroup/glslang.git";
              tag = "16.5.0";
              sha256 = "sha256-usrfmjyJjumM/pjMGa59tHaQ6b2tC5hNSjgSZY3YGkI=";
            };

            buildInputs = with pkgs; [
              stdenv.cc.cc
              ninja
              python3
              git
              zlib
              cmake
              pkg-config
              spirv-tools
              glslang
            ];

            patchPhase = ''
              patch CMakeLists.txt ${self}/axslcc-legacy.CMakeLists.txt.patch
              cat CMakeLists.txt
            '';

            configurePhase = ''
              echo COPYING
              cp ${glslang-repo} 3rdparty/glslang -r
              chmod -R u+rwX 3rdparty/glslang

              mkdir -p build
              cd build
              cmake .. -DCMAKE_BUILD_TYPE=Release
            '';

            buildPhase = ''
              ls
              echo $(find . -name "CMakeLists.txt")

              make -j$(nproc)
            '';

            installPhase = ''
              mkdir -p $out/bin

              cp src/glslcc $out/bin/glslcc
              ln -s $out/bin/glslcc $out/bin/axslcc
            '';
          };

          default = axslcc-legacy;
        };
      }
    );
}
