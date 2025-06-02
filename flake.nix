{
  description = "hledger-iadd";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    my-utils = {
      url = "github:ShrykeWindgrace/haskell-flake-utilities";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, my-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        haskellPackages = pkgs.haskellPackages.extend (final: prev: {
          hledger-lib = pkgs.haskell.lib.doJailbreak prev.hledger-lib_1_42_1;
        });

        packageName = "hledger-iadd";
      in
      {
        packages.${packageName} = my-utils.packagePostOverrides.${system}
          (haskellPackages.callCabal2nix packageName self rec { });
        packages.default = self.packages.${system}.hledger-iadd;

        devShells.default = my-utils.shellNoCC.${system} { };
        devShells.custom-shell = my-utils.shellNoCC.${system} {
          inputsFrom = map (__getAttr "env") (__attrValues self.packages.${system});
        };
        devShell = self.devShells.${system}.default;
        formatter = pkgs.nixpkgs-fmt;
      });
}
