{
  description = "on god, a verifpal flake indeed";

  inputs = {
    nixpkgs.url    = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        ##########################################
        ## (1) The “verifpal” package itself:  ##
        ##########################################
        packages.default = pkgs.stdenv.mkDerivation {
          pname    = "verifpal";
          version  = "0.1.0";
          src      = ./.;

          nativeBuildInputs = with pkgs; [
            go
            gnumake
            git
            pigeon
          ];

          patchPhase = ''
            substituteInPlace Makefile \
              --replace "go build"   "go build -mod=vendor" \
              --replace "go generate" "go generate -mod=vendor"

            mkdir -p build
          '';

          buildPhase = ''
            set -x
            go get -u github.com/logrusorgru/aurora
            go get -u github.com/josephspurrier/goversioninfo/cmd/goversioninfo
            export HOME=$(mktemp -d)
            export GOCACHE=$(mktemp -d)
            export GOFLAGS="-mod=vendor"
            make linux
          '';

          # (c) After the build, install the “build/linux” binary into $out/bin/verifpal
          installPhase = ''
            mkdir -p $out/bin
            cp build/linux $out/bin/verifpal
          '';

          # (d) Because we are not using buildGoModule, we do NOT need `vendorSha256`
          #     buildGoModule expects “vendorSha256 = …”, but mkDerivation does not.
        };

        ##########################################
        ## (2) A devShell with Go + make + tools ##
        ##########################################
        devShells.${system} = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gotools
            gnumake
          ];

          shellHook = ''
            echo "Entering Verifpal dev shell"
            export SHELL=${pkgs.zsh}/bin/zsh
            exec $SHELL
          '';
        };
      }
    );
}
