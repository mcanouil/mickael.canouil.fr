#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

new_screenshots="$(mktemp -d)"
trap 'rm -rf "${new_screenshots}"' EXIT
npx -y decktape reveal \
	--chrome-arg=--no-sandbox \
	--chrome-arg=--disable-setuid-sandbox \
	--fragments \
	--screenshots \
	--screenshots-format png \
	--screenshots-directory "${new_screenshots}" \
	--size "1280x640" \
	_demo-tabset.html _demo-tabset-2.pdf
rm -f _demo-tabset-2.pdf
rm -rf screenshots
mv "${new_screenshots}" screenshots
chmod 755 screenshots

magick \
	-delay 75 \
	screenshots/_demo-tabset*.png \
	-loop 0 \
	-duplicate 1,-2-1 \
	-layers OptimizePlus \
	-colors 256 \
	-quality 85 \
	../featured.gif
