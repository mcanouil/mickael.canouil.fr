#!/usr/bin/env bash
# Write the light and the dark variant of the radial before/after figure.
# The colours match the `background` and `foreground` this post declares for
# the typst-render extension, so the pair sits on the page like every other
# figure.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="${here}/.."

for mode in light dark; do
	typst compile \
		--root / \
		--input "mode=${mode}" \
		"${here}/polar-compare.typ" \
		"${out}/polar-${mode}.svg"
	printf 'written: %s\n' "${out}/polar-${mode}.svg"
done
