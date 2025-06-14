{
  description = "on god, a verifpal flake indeed";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname   = "verifpal";
          version = "0.1.0";
          src     = ./.;

          nativeBuildInputs = with pkgs; [
            go
            gnumake
            git
          ];

          patchPhase = ''
            substituteInPlace Makefile \
              --replace "go generate verifpal.com/cmd/verifpal" \
                        "echo \"[Verifpal] Skipping go generate (vendored)\"" 

            substituteInPlace Makefile \
              --replace "go build"   "go build -mod=vendor" 

            mkdir -p build
          '';

          buildPhase = ''
            # set -x
            export HOME=$(mktemp -d)
            export GOCACHE=$(mktemp -d)
            export GOFLAGS="-mod=vendor"
            make linux
          '';

          installPhase = ''
          mkdir -p $out/bin
            # cp -r build/linux $out/bin/verifpal
            # export PATH="$PATH:$out/bin/verifpal"
            cp build/linux/verifpal $out/bin/verifpal
          '';
        };

        devShells.default = pkgs.mkShellNoCC rec {
          buildInputs = with pkgs; [
            go
            gotools
            gnumake
            self.packages.${system}.default
          ];

          shellHook = ''
            echo "verifpal should now be in your path"
            export SHELL=${pkgs.zsh}/bin/zsh
            exec $SHELL
            export PATH="${self.packages.${system}.default}/bin:$PATH"
          '';
        };
      }
    );
}
