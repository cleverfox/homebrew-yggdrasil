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

# Replace the stable `url "..."` line (head uses `head "..."`, so it's safe to
# anchor on `url "`). sha256 appears exactly once (HEAD has no checksum).
# Line-anchored so any tag format works, including suffixes like -cf.
sed -i '' -E "s#^  url \".*\"#  url \"${URL}\"#" "$FORMULA"
sed -i '' -E "s#^  sha256 \".*\"#  sha256 \"${SHA}\"#" "$FORMULA"

echo "Updated $FORMULA"
echo "  version: $VERSION"
echo "  sha256:  $SHA"
echo
echo "Review, then commit & push:"
echo "  git -C \"$(dirname "$FORMULA")/..\" commit -am \"yggdrasil-ng $VERSION\" && git push"
