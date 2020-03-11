{ mkDerivation, aeson, aeson-qq, ansi-wl-pprint, async, auto-update
, base, base64-bytestring, bytestring, case-insensitive, cassava
, configurator-pg, containers, contravariant, contravariant-extras
, cookie, directory, either, fetchgit, gitrev, hasql, hasql-pool
, hasql-transaction, heredoc, hspec, hspec-wai, hspec-wai-json
, HTTP, http-types, insert-ordered-containers
, interpolatedstring-perl6, jose, lens, lens-aeson, monad-control
, network, network-uri, optparse-applicative, parsec, process
, protolude, Ranged-sets, regex-tdfa, retry, scientific, stdenv
, swagger2, text, time, transformers-base, unix
, unordered-containers, vector, wai, wai-cors, wai-extra
, wai-middleware-static, warp
}:
mkDerivation {
  pname = "postgrest";
  version = "5.2.0";
  src = fetchgit {
    url = "https://github.com/PostgREST/postgrest";
    sha256 = "140k30h51pd0yqiw9cqzpvz0fai00c6dscasrs19iy7f01vxlndp";
    rev = "40ae7ce2b1fe9d7582c4f8946c69563b07127e06";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson ansi-wl-pprint base base64-bytestring bytestring
    case-insensitive cassava configurator-pg containers contravariant
    contravariant-extras cookie either gitrev hasql hasql-pool
    hasql-transaction heredoc HTTP http-types insert-ordered-containers
    interpolatedstring-perl6 jose lens lens-aeson network-uri
    optparse-applicative parsec protolude Ranged-sets regex-tdfa
    scientific swagger2 text time unordered-containers vector wai
    wai-cors wai-extra wai-middleware-static
  ];
  executableHaskellDepends = [
    auto-update base base64-bytestring bytestring directory hasql
    hasql-pool hasql-transaction network protolude retry text time unix
    warp
  ];
  testHaskellDepends = [
    aeson aeson-qq async auto-update base base64-bytestring bytestring
    case-insensitive cassava containers contravariant hasql hasql-pool
    hasql-transaction heredoc hspec hspec-wai hspec-wai-json http-types
    lens lens-aeson monad-control process protolude regex-tdfa text
    time transformers-base wai wai-extra
  ];
  doHaddock = false;
  doCheck = false;
  homepage = "https://postgrest.org";
  description = "REST API for any Postgres database";
  license = stdenv.lib.licenses.mit;
}
