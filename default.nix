{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgs ? (import ./nix/pkgs.nix { inherit pkgsSrc; }).pkgs
}: with pkgs;

let
  inherit (callPackage ./nix/dapp.nix {}) this specs package;

  this-optimize = package (specs.this // {
    solcFlags = "--optimize";
  });

  mkScripts = { regex, name, solidityPackages }: makerScriptPackage {
    inherit name solidityPackages;
    src = lib.sourceByRegex ./bin (regex ++ [ ".*lib.*" ]);
    extraBins = [ git ];
    scriptEnv = {
      SKIP_BUILD = true;
    };
  };

  deploy-core = mkScripts {
    name = "dss-deploy-core";
    regex = [ "deploy-core" ];
    solidityPackages = [ this-optimize ];
  };

  deploy-fabs = mkScripts {
    name = "dss-deploy-fabs";
    regex = [ "deploy-fab" "deploy-ilk.*" ];
    solidityPackages = [ this ];
  };
in symlinkJoin {
  name = "dss-deploy";
  paths = [ deploy-fabs deploy-core ];
}
