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

  optimized = mkScripts {
    name = "dss-deploy-optimized";
    regex = [ "deploy-core" ];
    solidityPackages = [ this-optimize ];
  };

  nonOptimized = mkScripts {
    name = "dss-deploy-non-optimized";
    regex = [ "deploy-fab" "deploy-ilk.*" ];
    solidityPackages = [ this ];
  };
in symlinkJoin {
  name = "dss-deploy";
  paths = [ optimized nonOptimized ];
}
