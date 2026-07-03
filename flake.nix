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
      pname = "fluxer";
    in {
      packages.default = pkgs.appimageTools.wrapType2 {
        name = "fluxer-canary";
        inherit version pname;
        src = pkgs.fetchurl {
          url = "https://api.fluxer.app/dl/desktop/canary/linux/x64/${version}/appimage";
          hash = hash;
        };
        extraInstallCommands = ''
            # Create the applications directory
            mkdir -p "$out/share/applications"

            # Write a new desktop file (ignore anything inside $out/opt)
            cat > "$out/share/applications/$pname.desktop" <<EOF
          [Desktop Entry]
          Name=Fluxer Canary
          Comment=Fluxer desktop app
          Exec=$pname
          Icon=$pname
          Type=Application
          Categories=Utility;
          EOF

            # Optional: copy the icon from the extracted AppImage
            EXTRACTED="$out/opt/$pname"
            ICON=$(find "$EXTRACTED" -maxdepth 1 -name "*.png" -print -quit 2>/dev/null || true)
            if [ -n "$ICON" ]; then
              mkdir -p "$out/share/icons/hicolor/256x256/apps"
              cp "$ICON" "$out/share/icons/hicolor/256x256/apps/$pname.png"
            fi
        '';
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
