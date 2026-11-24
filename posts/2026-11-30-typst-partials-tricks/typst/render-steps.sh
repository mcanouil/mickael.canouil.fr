#!/usr/bin/env bash
# Render the demo report once per step: step N loads partials 1 to N.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
assets="$(dirname "$here")/assets"
last=10

cd "$here"
mkdir -p _steps "$assets"
quarto --version

body="$(awk 'BEGIN { n = 0 } /^---$/ && n < 2 { n++; next } n >= 2' _report.qmd)"
head_yaml="$(awk 'BEGIN { n = 0 } /^---$/ { n++; next } n == 1' _report.qmd)"

for ((step = 0; step <= last; step++)); do
	src="_step-${step}.qmd"
	{
		echo "---"
		echo "${head_yaml}"
		echo "format:"
		echo "  typst:"
		echo "    pdf-standard: ua-1"
		if ((step > 0)); then
			echo "    include-in-header:"
			for ((i = 1; i <= step; i++)); do
				printf '      - %s\n' partials/"${i}"-*.typ
			done
		fi
		if ((step >= 7)); then
			echo "    template-partials:"
			echo "      - typst-show.typ"
		fi
		echo "---"
		echo "${body}"
	} >"${src}"

	quarto render "${src}" --to typst -M keep-typ:true --quiet
	mv "_step-${step}.pdf" "_steps/step${step}.pdf"
	rm -f "${assets}/step${step}-p"*.png
	quarto typst compile "_step-${step}.typ" "${assets}/step${step}-p{p}.png" --ppi 80
	rm -f "${src}" "_step-${step}.typ"
	echo "step ${step}: $(pdfinfo "_steps/step${step}.pdf" | awk '/^Pages:/ { print $2 }') pages"
done

if ! pdfinfo "_steps/step${last}.pdf" | grep -Eq '^Tagged:[[:space:]]+yes'; then
	echo "error: _steps/step${last}.pdf is not tagged; check pdf-standard: ua-1." >&2
	exit 1
fi
echo "step ${last} is tagged."
