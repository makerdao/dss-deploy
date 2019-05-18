{ pkgsSrc ? (import ./pkgs.nix {}).pkgsSrc
, pkgs ? (import ./pkgs.nix { inherit pkgsSrc; }).pkgs
}: with pkgs;

let
  inherit (callPackage ./dapp.nix {}) this;
in

makerScriptPackage {
  name = "dss-deploy";
  src = ./bin;

  solidityPackage = [ this ];

  extraBins = [ git ];
  scriptEnv = {
    SKIP_BUILD = true;
  };
}
