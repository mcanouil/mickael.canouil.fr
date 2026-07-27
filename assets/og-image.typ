// Source for `assets/images/og-image.png`, the 1200x630 social preview card.
//
// Regenerate with:
//   typst compile --root . assets/og-image.typ assets/images/og-image.png --ppi 72
// The page is 1200pt by 630pt, so 72 ppi gives exactly 1200x630 pixels, and
// `--root .` lets the file reach the artwork under `_extensions/`.
//
// Colours come from `_extensions/mickaelcanouilfr/scss/_defaults.scss`.
// The title is the existing outlined wordmark rather than live text, so the
// card needs neither Dancing Script nor Alegreya SC to be installed.
//
// @license MIT
// @copyright 2026 Mickaël Canouil
// @author Mickaël Canouil

#let ink = rgb("#111827")
#let gold = rgb("#b5830a")
#let rule = rgb("#d1c4a0")

#set page(width: 1200pt, height: 630pt, margin: 0pt, fill: ink)
#set text(font: "Georgia", fill: rule)

#align(center + horizon)[
  #stack(
    dir: ttb,
    spacing: 26pt,
    image("images/icon.svg", width: 100pt),
    image("/_extensions/mickaelcanouilfr/assets/images/logo-gold-path.svg", width: 560pt),
    line(length: 240pt, stroke: 1.5pt + gold),
    text(size: 36pt, style: "italic")[Biostatistician, Quarto wizard, and cinephile.],
  )
]
