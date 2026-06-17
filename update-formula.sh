#!/bin/bash
# Update a formula's stable source pointer for a given release tag, after you
# push a "v<version>" tag to the corresponding upstream repo.
#
# Usage: ./update-formula.sh <formula> <version>
#   ./update-formula.sh yggdrasil-ng 0.1.6-cf
#   ./update-formula.sh yggstack-ng  0.1.0-cf
#
# Strategies differ per formula:
#   yggdrasil-ng - plain source tarball + sha256 (no submodules)
#   yggstack-ng  - git tag + revision (it has a submodule; tarballs omit those)
set -euo pipefail

FORMULA_NAME="${1:?usage: update-formula.sh <formula> <version>}"
VERSION="${2:?usage: update-formula.sh <formula> <version>}"
TAG="v$VERSION"
DIR="$(cd "$(dirname "$0")" && pwd)"
FORMULA="$DIR/Formula/$FORMULA_NAME.rb"

[ -f "$FORMULA" ] || { echo "No such formula: $FORMULA" >&2; exit 1; }

case "$FORMULA_NAME" in
  yggdrasil-ng) REPO="cleverfox/yggdrasil-ng"; STRATEGY="tarball" ;;
  yggstack-ng)  REPO="cleverfox/yggstack-ng";  STRATEGY="git" ;;
  *) echo "Unknown formula '$FORMULA_NAME' (expected yggdrasil-ng or yggstack-ng)" >&2; exit 1 ;;
esac

if [ "$STRATEGY" = "tarball" ]; then
  URL="https://github.com/$REPO/archive/refs/tags/$TAG.tar.gz"
  echo "Downloading $URL ..."
  TMP="$(mktemp)"
  trap 'rm -f "$TMP"' EXIT
  curl -fSL "$URL" -o "$TMP"
  SHA="$(shasum -a 256 "$TMP" | awk '{print $1}')"

  # Line-anchored so any tag format works (head uses `head "..."`, not `url`).
  sed -i '' -E "s#^  url \".*\"#  url \"${URL}\"#" "$FORMULA"
  sed -i '' -E "s#^  sha256 \".*\"#  sha256 \"${SHA}\"#" "$FORMULA"
  echo "Updated $FORMULA -> $TAG (sha256 $SHA)"
else
  # git strategy: resolve the commit the tag points to (peeled, for annotated
  # tags; fall back to the ref itself for lightweight tags).
  REV="$(git ls-remote "https://github.com/$REPO.git" "refs/tags/$TAG^{}" | awk '{print $1}')"
  [ -n "$REV" ] || REV="$(git ls-remote "https://github.com/$REPO.git" "refs/tags/$TAG" | awk '{print $1}')"
  [ -n "$REV" ] || { echo "Tag $TAG not found on $REPO (push it first)" >&2; exit 1; }

  # Update the multi-line `url "...git", tag: "...", revision: "..."` block.
  sed -i '' -E "s#^      tag: *\".*\"#      tag:      \"${TAG}\"#" "$FORMULA"
  sed -i '' -E "s#^      revision: *\".*\"#      revision: \"${REV}\"#" "$FORMULA"
  echo "Updated $FORMULA -> $TAG (revision $REV)"
fi

echo
echo "Review, then commit & push:"
echo "  git -C \"$DIR\" commit -am \"$FORMULA_NAME $VERSION\" && git push"
