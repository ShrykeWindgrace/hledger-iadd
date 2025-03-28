{
  description = "hledger-iadd";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        haskellPackages = pkgs.haskellPackages.extend (final: prev: {
          #hledger = prev.hledger_1_22_2;
          hledger-lib = prev.hledger-lib_1_40;
        });
        packagePostOverrides = pkg: with pkgs.haskell.lib.compose; pkgs.lib.pipe pkg [
          disableExecutableProfiling
          disableLibraryProfiling
          dontBenchmark
          dontCoverage
          dontDistribute
          dontHaddock
          dontHyperlinkSource
          doStrip
          enableDeadCodeElimination
          justStaticExecutables

          dontCheck
        ];

        packageName = "hledger-iadd";
      in
      {
        packages.${packageName} = packagePostOverrides
          (haskellPackages.callCabal2nix packageName self rec { });
        packages.default = self.packages.${system}.hledger-iadd;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
          ];
          inputsFrom = map (__getAttr "env") (__attrValues self.packages.${system});
        };
        devShell = self.devShells.${system}.default;
      });
}
