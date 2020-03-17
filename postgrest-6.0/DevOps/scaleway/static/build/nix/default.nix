{ compiler ? "ghc865" }:

let
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = haskellPackagesNew: haskellPackagesOld: rec {

              postgrest =
                haskellPackagesNew.callPackage ./postgrest.nix { };
            };
          };
        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; };

  inherit (pkgs) dockerTools stdenv buildEnv writeText;

  postgrest = pkgs.haskell.packages.${compiler}.postgrest;

  static-postgrest = pkgs.haskell.lib.justStaticExecutables pkgs.haskell.packages.${compiler}.postgrest;

  passwd = ''
    root:x:0:0::/root:/run/current-system/sw/bin/bash
    postgrest:x:90001:90001::/var/empty:/run/current-system/sw/bin/nologin
  '';

  group = ''
    root:x:0:
    nogroup:x:65534:
    postgrest:x:90001:postgrest
  '';

  nsswitch = ''
    hosts: files dns myhostname mymachines
  '';

  postgrest-conf = ''
    para1 = "$(PARA1)"
    para2 = "$(PARA2)"
  '';

  postgrest-env = stdenv.mkDerivation {
    name = "postgrest-env";
    phases = [ "installPhase" "fixupPhase" ];

    installPhase = ''
      mkdir -p $out/etc/postgrest
      echo '${postgrest-conf}' > $out/etc/postgrest/postgrest.conf
      echo '${passwd}' > $out/etc/passwd
      echo '${group}' > $out/etc/group
      echo '${nsswitch}' > $out/etc/nsswitch.conf
    '';
  };

  postgrest-docker =  pkgs.dockerTools.buildImage {
  name = "postgrest";
  tag = postgrest.version;
  
  contents = [ static-postgrest
               postgrest-env ];
  config = {
    Env = [ 
    "PARA1="
    "PARA2="
    ];
    User = "postgrest";
    Cmd = [ "${static-postgrest}/bin/postgrest" "/etc/postgrest/postgrest.conf" ];
    ExposedPorts = {
      "5432/tcp" = {};
    };
    WorkingDir = "/data";
    Volumes = {
      "/data" = {};
    };
  };
};
in  {
  inherit postgrest;
  inherit static-postgrest;
  inherit postgrest-docker;
}
