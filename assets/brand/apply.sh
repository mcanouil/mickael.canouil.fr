#!/usr/bin/env bash
# Apply the gold variant of the brand to the site: the icons, the wordmarks,
# and the social card.
#
# Usage: assets/brand/apply.sh
#
# Run it after a change to a file in `assets/brand`, then commit the results.
# `render.sh` does not run it: the large mark samples a font through a
# Chromium canvas, so a browser or font update can move its points. Running
# the build only on purpose keeps the committed files stable between renders.
#
# The gold variant comes from the site palette in
# `_extensions/mickaelcanouilfr/scss/_defaults.scss`, so a colour change there
# reaches the brand at the next run. `build.sh` colours the editable sources
# with it and writes `roles.env`, the colour of each role. That file sets the
# Apple touch icon background and the social card colours below.
# Every raster is derived from the built SVG files, and the card from
# `assets/og-image.typ`. Needs what `build.sh` needs, plus `rsvg-convert`
# (librsvg), ImageMagick, and Typst.
#
# @license MIT
# @copyright 2026 Mickaël Canouil
# @author Mickaël Canouil

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."
export CHROME_PATH="${CHROME_PATH:-${CHROMOTE_CHROME:-/Applications/Brave Browser.app/Contents/MacOS/Brave Browser}}"

brand_build="$(mktemp -d)"
trap 'rm -rf "${brand_build}"' EXIT

scss=_extensions/mickaelcanouilfr/scss/_defaults.scss
scss_colour() {
	local value
	value="$(sed -n "s/^\\\$mc-$1: *\(#[0-9a-fA-F]\{6\}\).*/\1/p" "${scss}")"
	if [[ -z "${value}" ]]; then
		echo "Error: '${scss}' does not set \$mc-$1 to a #rrggbb colour." >&2
		exit 65
	fi
	printf '%s' "${value}"
}
paper="$(scss_colour paper)"
ink="$(scss_colour ink)"
accent="$(scss_colour accent)"
ink_dark="$(scss_colour ink-dark)"
variant="${brand_build}/gold.yml"
cat >"${variant}" <<VARIANT
light:
  paper: "${paper}"
  ink: "${ink}"
  accent: "${accent}"
  ground-1: "${ink}"
dark:
  ink: "${ink_dark}"
VARIANT

built="${brand_build}/out"
assets/brand/build.sh "${variant}" "${built}"
field="$(sed -n 's/^field=//p' "${built}/roles.env")"
accent="$(sed -n 's/^accent=//p' "${built}/roles.env")"
cp "${built}/icon.svg" "${built}/mark.svg" assets/images/
cp "${built}"/logo-*.svg _extensions/mickaelcanouilfr/assets/images/

# `favicon.ico` uses the small icon, which stays legible at 16 and 32 px.
# The other icons use the large mark.
# The Apple touch icon is composited onto a larger opaque canvas rather than
# scaled, so it carries the padding and the flat background that Apple asks
# for, with no self-applied rounded corners. `-strip` drops the creation
# timestamp that ImageMagick would otherwise write, so a rebuild of the same
# input gives the same file.
rsvg-convert -w 192 -h 192 assets/images/mark.svg -o assets/images/icon-192.png
rsvg-convert -w 512 -h 512 assets/images/mark.svg -o assets/images/icon-512.png
rsvg-convert -w 160 -h 160 assets/images/mark.svg -o "${brand_build}/mark-160.png"
magick -size 180x180 xc:"${field}" "${brand_build}/mark-160.png" -gravity center -composite -alpha off -strip assets/images/apple-touch-icon.png
rsvg-convert -w 32 -h 32 assets/images/icon.svg -o "${brand_build}/icon-32.png"
magick "${brand_build}/icon-32.png" -define icon:auto-resize=32 favicon.ico
# 1200pt by 630pt at 72 ppi is exactly the 1200x630 that Open Graph expects.
typst compile --root . --input field="${field}" --input accent="${accent}" assets/og-image.typ assets/images/og-image.png --ppi 72
