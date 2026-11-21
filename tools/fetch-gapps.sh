#!/bin/bash
# Download the KIC OS GApps package (private release asset) into vendor/kic/gapps.
# Needs: gh logged in with access to kichukic/android_vendor_kic_gapps.
set -e
KIC="$(cd "$(dirname "$0")/.." && pwd)"
REPO="kichukic/android_vendor_kic_gapps"
TAG="${GAPPS_TAG:-$(gh release view -R "$REPO" --json tagName -q .tagName)}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Fetching GApps $TAG from $REPO"
gh release download "$TAG" -R "$REPO" -D "$TMP" -p 'kic-gapps-*.tar' -p 'kic-gapps-*.tar.sha256'
(cd "$TMP" && sha256sum -c kic-gapps-*.tar.sha256)
rm -rf "$KIC/gapps"
mkdir -p "$KIC/gapps"
tar -xf "$TMP"/kic-gapps-*.tar -C "$KIC/gapps"
echo "GApps ready in $KIC/gapps"
