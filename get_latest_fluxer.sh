#/usr/bin/env bash

FLUXER_API_URL="https://api.fluxer.app/dl/desktop/canary/linux/x64/latest"

if ! command -v curl >/dev/null; then
  echo -e "Curl is not installed. Please install curl and try again."
  exit 1
fi

if ! command -v jq >/dev/null; then
  echo -e "jq is not installed. Please install jq and try again."
  exit 1
fi

if ! command -v nix-prefetch-url >/dev/null; then
  echo -e "nix-prefetch-url is not installed. Please install nix-prefetch-url and try again."
  exit 1
fi

if ! command -v nix >/dev/null; then
  echo -e "nix is not installed. Please install nix and try again."
  exit 1
fi

VERSION=$(curl -s "$FLUXER_API_URL" | jq -r '.version')
HASH=$(nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url https://api.fluxer.app/dl/desktop/canary/linux/x64/${VERSION}/appimage))

echo "{ \"version\": \"$VERSION\", \"hash\": \"$HASH\" }" > ./fluxer_version.json

