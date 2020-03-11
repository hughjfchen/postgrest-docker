{ compiler ? "ghc865" }:

let
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = haskellPackagesNew: haskellPackagesOld: rec {

              swagger2 =
                haskellPackagesNew.callPackage ./swagger2.nix { };

              hasql-pool =
                haskellPackagesNew.callPackage ./hasql-pool.nix { };

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

  postgrestconf = ''
    db-uri = "$(PGRST_DB_URI)"
    db-schema = "$(PGRST_DB_SCHEMA)"
    db-anon-role = "$(PGRST_DB_ANON_ROLE)"
    db-pool = "$(PGRST_DB_POOL)"
    db-extra-search-path = "$(PGRST_DB_EXTRA_SEARCH_PATH)"

    server-host = "$(PGRST_SERVER_HOST)"

    server-port = "$(PGRST_SERVER_PORT)"

    server-proxy-uri = "$(PGRST_SERVER_PROXY_URI)"
    jwt-secret = "$(PGRST_JWT_SECRET)"
    secret-is-base64 = "$(PGRST_SECRET_IS_BASE64)"
    jwt-aud = "$(PGRST_JWT_AUD)"
    role-claim-key = "$(PGRST_ROLE_CLAIM_KEY)"

    max-rows = "$(PGRST_MAX_ROWS)"
    pre-request = "$(PGRST_PRE_REQUEST)" 
  '';

  postgrest-env = stdenv.mkDerivation {
    name = "postgrest-env";
    phases = [ "installPhase" "fixupPhase" ];

    installPhase = ''
      mkdir -p $out/etc/postgrest
      echo '${postgrestconf}' > $out/etc/postgrest/postgrest.conf
      echo '${passwd}' > $out/etc/passwd
      echo '${group}' > $out/etc/group
      echo '${nsswitch}' > $out/etc/nsswitch.conf
    '';
  };

  postgrest-docker =  pkgs.dockerTools.buildImage {
  name = "postgrest";
  tag = "6.0.2";
  
  contents = [ static-postgrest
               postgrest-env ];
  config = {
    Env = [ 
    "PGRST_DB_URI="
    "PGRST_DB_SCHEMA=public"
    "PGRST_DB_ANON_ROLE="
    "PGRST_DB_POOL=100"
    "PGRST_DB_EXTRA_SEARCH_PATH=public"
    "PGRST_SERVER_HOST=*4"
    "PGRST_SERVER_PORT=3000"
    "PGRST_SERVER_PROXY_URI="
    "PGRST_JWT_SECRET="
    "PGRST_SECRET_IS_BASE64=false"
    "PGRST_JWT_AUD="
    "PGRST_MAX_ROWS="
    "PGRST_PRE_REQUEST="
    "PGRST_ROLE_CLAIM_KEY=.role"
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
