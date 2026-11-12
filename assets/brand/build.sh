#!/usr/bin/env bash
# Build the brand marks of mickael.canouil.fr in the colours and faces of a
# variant file.
#
# Usage: assets/brand/build.sh <variant.yml> <output-directory>
#
# The variant file uses the token names of the quarto-mcanouil presets, so a
# preset file of that extension works as it is. Each colour role takes the
# first token in its list that has enough contrast against its background:
# 3:1 for graphics, 4.5:1 for the logos. If no token is high enough, the role
# takes the token with the highest contrast, and the script shows a warning.
# Tokens that the file does not set are skipped.
#
#   role          background        tokens, in order
#   field         none              light.ground-1 (must be set)
#   letter        field             dark.ink, light.on-ground-title
#   accent        field             light.accent, light.accent-high,
#                                   light.on-ground-accent
#   accent-dark   letter            light.accent, light.accent-low,
#                                   light.accent-text
#   ink logo      white             light.ink, dark.paper, light.ground-1
#   paper logo    field             light.paper, dark.ink,
#                                   light.on-ground-title
#
# `letter` draws the baseline, the dot, and the M of the icon and the mark.
# `accent-dark` is the curve of the icon in the dark browser theme, where the
# field and the letter colours swap.
# Faces, both optional:
#   fonts.script     the script face (default Dancing Script);
#   fonts.capitals   the small-capital face (default Alegreya SC).
#
# The script writes these files to the output directory:
#   icon.svg          small icon, the bimodal M, flips with the browser theme;
#   mark.svg          large mark, the quasi-Monte Carlo MC;
#   logo-accent.svg   wordmark in the accent role;
#   logo-ink.svg      wordmark in the ink logo role, for light backgrounds;
#   logo-paper.svg    wordmark in the paper logo role, for dark backgrounds.
# The logos are outlined, so they need no font.
#
# The sources in this folder do not change: `icon.svg`, `mark.html`, and
# `logo.svg`. Needs yq (mikefarah), perl, fontconfig, Inkscape, and a Chromium-based
# browser in `CHROME_PATH` or `CHROMOTE_CHROME`. The script and the logo
# faces must be installed.
#
# @license MIT
# @copyright 2026 Mickaël Canouil
# @author Mickaël Canouil

set -euo pipefail

if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <variant.yml> <output-directory>" >&2
	exit 64
fi

variant="$1"
output="$2"
brand_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
browser="${CHROME_PATH:-${CHROMOTE_CHROME:-}}"

if [[ ! -f "${variant}" ]]; then
	echo "Error: variant file '${variant}' does not exist." >&2
	exit 66
fi
if [[ -z "${browser}" || ! -x "${browser}" ]]; then
	echo "Error: set CHROME_PATH or CHROMOTE_CHROME to a Chromium-based browser." >&2
	exit 69
fi

read_colour() {
	local value
	value="$(yq -r ".${1}.\"${2}\"" "${variant}")"
	if [[ ! "${value}" =~ ^#[0-9a-fA-F]{6}$ ]]; then
		echo "Error: '${1}.${2}' in '${variant}' is '${value}', expected a #rrggbb colour." >&2
		exit 65
	fi
	printf '%s' "${value,,}"
}

read_optional() {
	local value
	value="$(yq -r ".${1} // \"\"" "${variant}")"
	if [[ -n "${value}" && ! "${value}" =~ ^#[0-9a-fA-F]{6}$ ]]; then
		echo "Error: '${1}' in '${variant}' is '${value}', expected a #rrggbb colour." >&2
		exit 65
	fi
	printf '%s' "${value,,}"
}

contrast() {
	perl -e '
		sub lum {
			my @c = map {
				my $v = hex($_) / 255;
				$v <= 0.04045 ? $v / 12.92 : (($v + 0.055) / 1.055)**2.4
			} ($_[0] =~ /#(..)(..)(..)/);
			return 0.2126 * $c[0] + 0.7152 * $c[1] + 0.0722 * $c[2];
		}
		my ($a, $b) = (lum($ARGV[0]), lum($ARGV[1]));
		($a, $b) = ($b, $a) if $b > $a;
		printf "%.2f", ($a + 0.05) / ($b + 0.05);
	' "$1" "$2"
}

# pick <role> <background> <minimum> <token>...
pick() {
	local role="$1" background="$2" minimum="$3" token colour ratio
	local best="" best_token="" best_ratio="0"
	shift 3
	for token in "$@"; do
		colour="$(read_optional "${token}")"
		[[ -z "${colour}" ]] && continue
		ratio="$(contrast "${colour}" "${background}")"
		if perl -e 'exit(!($ARGV[0] >= $ARGV[1]))' "${ratio}" "${minimum}"; then
			echo "  ${role}: ${token} ${colour}, ${ratio}:1 on ${background}" >&2
			printf '%s' "${colour}"
			return
		fi
		if perl -e 'exit(!($ARGV[0] > $ARGV[1]))' "${ratio}" "${best_ratio}"; then
			best="${colour}" best_token="${token}" best_ratio="${ratio}"
		fi
	done
	if [[ -z "${best}" ]]; then
		echo "Error: '${variant}' sets none of these tokens for ${role}: $*." >&2
		exit 65
	fi
	echo "  Warning: ${role}: no token reaches ${minimum}:1 on ${background}; using ${best_token} ${best}, ${best_ratio}:1." >&2
	printf '%s' "${best}"
}

read_font() {
	local value
	value="$(yq -r ".fonts.\"${1}\" // \"\"" "${variant}")"
	printf '%s' "${value:-$2}"
}

mix() {
	local from="${1#\#}" to="${2#\#}" percent="$3" result="#" i a b
	for i in 0 2 4; do
		a=$((16#${from:i:2}))
		b=$((16#${to:i:2}))
		result+="$(printf '%02x' $(((a * (100 - percent) + b * percent + 50) / 100)))"
	done
	printf '%s' "${result}"
}

echo "Colour roles for ${variant}:" >&2
field="$(read_colour light ground-1)"
letter="$(pick letter "${field}" 3 dark.ink light.on-ground-title)"
accent="$(pick accent "${field}" 3 light.accent light.accent-high light.on-ground-accent)"
accent_dark="$(pick accent-dark "${letter}" 3 light.accent light.accent-low light.accent-text)"
ink="$(pick "ink logo" "#ffffff" 4.5 light.ink dark.paper light.ground-1)"
paper="$(pick "paper logo" "${field}" 4.5 light.paper dark.ink light.on-ground-title)"
ghost="$(mix "${field}" "${letter}" 12)"
script_font="$(read_font script "Dancing Script")"
capitals_font="$(read_font capitals "Alegreya SC")"

for font in "${script_font}" "${capitals_font}"; do
	if ! fc-list ":family=${font}" family | grep -q .; then
		echo "Error: the face '${font}' is not installed." >&2
		exit 69
	fi
done

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
mkdir -p "${output}"

replace_style() {
	STYLE="$1" perl -0777 -pe 's{<style>.*?</style>}{<style>$ENV{STYLE}</style>}s'
}

replace_style "
    .field { fill: ${field}; }
    .accent { fill: ${accent}; stroke: ${accent}; }
    .letter { fill: ${letter}; stroke: ${letter}; }
    @media (prefers-color-scheme: dark) {
      .field { fill: ${letter}; }
      .accent { fill: ${accent_dark}; stroke: ${accent_dark}; }
      .letter { fill: ${field}; stroke: ${field}; }
    }
  " <"${brand_dir}/icon.svg" >"${output}/icon.svg"

cp "${brand_dir}/mark.html" "${work}/mark.html"
font_query="$(perl -e '$_ = shift; s/([^A-Za-z0-9._~-])/sprintf("%%%02X", ord($1))/ge; print' "${script_font}")"
"${browser}" --headless=new --disable-gpu --virtual-time-budget=5000 \
	--dump-dom "file://${work}/mark.html?font=${font_query}" 2>/dev/null >"${work}/mark-dom.html"
if ! grep -q '<svg' "${work}/mark-dom.html"; then
	echo "Error: the mark page wrote no SVG for the face '${script_font}'." >&2
	perl -0777 -ne 'print "$1\n" if m{<p id="error">(.*?)</p>}s' "${work}/mark-dom.html" >&2
	exit 70
fi
perl -0777 -ne 'print "$1\n" if m{(<svg.*?</svg>)}s' "${work}/mark-dom.html" |
	replace_style "
    .field { fill: ${field}; }
    .ghost { fill: ${ghost}; }
    .accent { fill: ${accent}; }
    .letter { fill: ${letter}; }
  " >"${output}/mark.svg"

SCRIPT_FONT="${script_font}" CAPITALS_FONT="${capitals_font}" perl -pe '
	s{(<text id="script"[^>]*font-family=")[^"]*}{$1$ENV{SCRIPT_FONT}};
	s{(<text id="capitals"[^>]*font-family=")[^"]*}{$1$ENV{CAPITALS_FONT}};
' "${brand_dir}/logo.svg" >"${work}/logo.svg"
inkscape "${work}/logo.svg" --export-text-to-path --export-plain-svg \
	--export-filename="${work}/logo-outlined.svg" 2>/dev/null
if grep -q '<text' "${work}/logo-outlined.svg"; then
	echo "Error: Inkscape left text in the logo." >&2
	exit 70
fi
sed "s/#010203/${accent}/g" "${work}/logo-outlined.svg" >"${output}/logo-accent.svg"
sed "s/#010203/${ink}/g" "${work}/logo-outlined.svg" >"${output}/logo-ink.svg"
sed "s/#010203/${paper}/g" "${work}/logo-outlined.svg" >"${output}/logo-paper.svg"

echo "Wrote icon.svg, mark.svg, logo-accent.svg, logo-ink.svg, and logo-paper.svg to ${output}."
echo "Faces: script '${script_font}', capitals '${capitals_font}'."
