#!/bin/bash
# Update the stable url + sha256 in Formula/yggdrasil-ng.rb for a given release
# tag. Run after pushing a vX.Y.Z tag to cleverfox/yggdrasil-ng.
#
# Usage: ./update-formula.sh 0.1.6
set -euo pipefail

VERSION="${1:?usage: update-formula.sh <version, e.g. 0.1.6>}"
REPO="cleverfox/yggdrasil-ng"
URL="https://github.com/$REPO/archive/refs/tags/v$VERSION.tar.gz"
FORMULA="$(cd "$(dirname "$0")" && pwd)/Formula/yggdrasil-ng.rb"

echo "Downloading $URL ..."
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
curl -fSL "$URL" -o "$TMP"
SHA="$(shasum -a 256 "$TMP" | awk '{print $1}')"

# Stable url is the only "archive/refs/tags/vX.tar.gz" line; HEAD uses .git.
# sha256 appears exactly once (HEAD has no checksum).
sed -i '' -E "s#archive/refs/tags/v[0-9][0-9.]*\.tar\.gz#archive/refs/tags/v${VERSION}.tar.gz#" "$FORMULA"
sed -i '' -E "s#sha256 \"[0-9a-f]{0,64}\"#sha256 \"${SHA}\"#" "$FORMULA"

echo "Updated $FORMULA"
echo "  version: $VERSION"
echo "  sha256:  $SHA"
echo
echo "Review, then commit & push:"
echo "  git -C \"$(dirname "$FORMULA")/..\" commit -am \"yggdrasil-ng $VERSION\" && git push"
