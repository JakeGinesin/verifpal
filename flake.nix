{
  description = "on god, a verifpal flake indeed";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; 
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.buildGoModule {
          pname = "verifpal";
          version = "0.1.0"; 
          src = ./.;

          vendorHash = "sha256-SnNBxRBcBdsZK87aHghH336k0meJKtleOdQnWMIPAXQ="; 
        };

        devShells.${system} = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gotools
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
