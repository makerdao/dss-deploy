{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgs ? (import ./nix/pkgs.nix { inherit pkgsSrc; }).pkgs
}: with pkgs;

let
  inherit (callPackage ./nix/dapp.nix {}) this;
in

makerScriptPackage {
  name = "dss-deploy";
  src = ./bin;

  solidityPackages = [ this ];

  extraBins = [ git ];
  scriptEnv = {
    SKIP_BUILD = true;
  };
}
