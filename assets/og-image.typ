// Source for `assets/images/og-image.png`, the 1200x630 social preview card.
//
// `assets/brand/apply.sh` compiles it with the `field` and `accent` colours that
// `assets/brand/build.sh` resolves for the gold variant, passed as inputs:
//   typst compile --root . --input field=#111827 --input accent=#b5830a \
//     assets/og-image.typ assets/images/og-image.png --ppi 72
// The page is 1200pt by 630pt, so 72 ppi gives exactly 1200x630 pixels, and
// `--root .` lets the file reach the artwork under `_extensions/`.
//
// The mark and the wordmark come from `assets/brand/build.sh` as well.
// The subtitle colour is a muted gold that no preset token gives.
// The title is the existing outlined wordmark rather than live text, so the
// card needs neither Dancing Script nor Alegreya SC to be installed.
//
// @license MIT
// @copyright 2026 Mickaël Canouil
// @author Mickaël Canouil

#let ink = rgb(sys.inputs.field)
#let gold = rgb(sys.inputs.accent)
#let rule = rgb("#d1c4a0")

#set page(width: 1200pt, height: 630pt, margin: 0pt, fill: ink)
#set text(font: "Georgia", fill: rule)

#align(center + horizon)[
  #stack(
    dir: ttb,
    spacing: 26pt,
    image("images/mark.svg", width: 150pt),
    image("/_extensions/mickaelcanouilfr/assets/images/logo-accent.svg", width: 560pt),
    line(length: 240pt, stroke: 1.5pt + gold),
    text(size: 36pt, style: "italic")[Biostatistician, Quarto wizard, and cinephile.],
  )
]
