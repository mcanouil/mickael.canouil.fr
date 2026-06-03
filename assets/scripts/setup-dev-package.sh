#!/usr/bin/env bash
# TEMPORARY drafting aid. Delete the call once the target version is published on
# Typst Universe.
#
# Stages a Typst package development build into Typst's `@preview` cache under a
# chosen version, so a post can `#import "@preview/<package>:<version>"` before
# that version exists on Typst Universe. Typst downloads the real package once it
# is published; until then this fills the cache slot.
#
# Usage:
#   _setup-dev-package.sh [VERSION] [PACKAGE] [DEV_URL]
#
# Defaults:
#   VERSION  0.2.0
#   PACKAGE  gribouille
#   DEV_URL  https://m.canouil.dev/<PACKAGE>/dev/<PACKAGE>.tar.gz
#
# Examples:
#   ./_setup-dev-package.sh                 # gribouille 0.2.0
#   ./_setup-dev-package.sh 0.3.0           # next gribouille release
#   ./_setup-dev-package.sh 1.0.0 mypkg https://example.com/mypkg.tar.gz
set -euo pipefail

VERSION="${1:-0.2.0}"
PACKAGE="${2:-gribouille}"
DEV_URL="${3:-https://m.canouil.dev/${PACKAGE}/dev/${PACKAGE}.tar.gz}"

case "$(uname -s)" in
Darwin) CACHE="${HOME}/Library/Caches/typst/packages/preview" ;;
*) CACHE="${XDG_CACHE_HOME:-${HOME}/.cache}/typst/packages/preview" ;;
esac
DEST="${CACHE}/${PACKAGE}/${VERSION}"

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

curl -fLo "${tmp}/package.tar.gz" "${DEV_URL}"
rm -rf "${DEST}"
mkdir -p "${DEST}"
tar -xzf "${tmp}/package.tar.gz" --strip-components=1 -C "${DEST}"

# The development archive is versioned by its build date; rewrite the manifest so
# the `@preview` directory name matches the version Typst requires.
sed -E -i.bak "s/^version[[:space:]]*=.*/version = \"${VERSION}\"/" "${DEST}/typst.toml"
rm -f "${DEST}/typst.toml.bak"

echo "Staged @preview/${PACKAGE}:${VERSION} at ${DEST}"
