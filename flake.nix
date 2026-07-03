{
  description = "Fluxer Canary – always latest x64 AppImage";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      fluxer_meta = pkgs.lib.importJSON ./fluxer_version.json;
      version = fluxer_meta.version;
      hash = fluxer_meta.hash;
    in {
      packages.default = pkgs.appimageTools.wrapType2 {
        name = "fluxer-canary";
        version = "${version}";
        pname = "fluxer";
        src = pkgs.fetchurl {
          url = "https://api.fluxer.app/dl/desktop/canary/linux/x64/${version}/appimage";
          hash = hash;
        };
      };
      devShells.default = pkgs.mkShell {
        name = "fluxer-canary";

        packages = with pkgs; [
          curl
          jq
        ];
      };
    });
}
