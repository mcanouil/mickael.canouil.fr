// Source for `assets/images/og-image.png`, the 1200x630 social preview card.
//
// The card shows a Monte Carlo estimate of the bimodal density of the small
// icon: points on a Halton sequence cover the card, and the points that fall
// under the curve take the accent colour. The dotted MC mark sits in the top
// left corner, and the wordmark and the tagline are centred at the top.
//
// `assets/brand/apply.sh` compiles it with the `field`, `accent`, and `ghost`
// colours that `assets/brand/build.sh` resolves for the gold variant:
//   typst compile --root . --input field=#111827 --input accent=#b5830a \
//     --input ghost=#2c3340 assets/og-image.typ assets/images/og-image.png --ppi 72
// The page is 1200pt by 630pt, so 72 ppi gives exactly 1200x630 pixels, and
// `--root .` lets the file reach the artwork under `_extensions/`.
//
// The mark and the wordmark come from `assets/brand/build.sh` as well.
// The tagline colour is a muted gold that no preset token gives.
// The title is the outlined wordmark rather than live text, so the card needs
// neither Dancing Script nor Alegreya SC to be installed.
//
// @license MIT
// @copyright 2026 Mickaël Canouil
// @author Mickaël Canouil

#let ink = rgb(sys.inputs.field)
#let gold = rgb(sys.inputs.accent)
#let ghost = rgb(sys.inputs.ghost)
#let tagline-colour = rgb("#d1c4a0")

#set page(width: 1200pt, height: 630pt, margin: 0pt, fill: ink)
#set text(font: "Georgia", fill: tagline-colour)

// Mixture of two normal densities, peaks at 0.3 and 0.7, scaled to a maximum of 1.
#let density(t) = {
  let normal(t, mean) = calc.exp(-calc.pow(t - mean, 2) / (2 * calc.pow(0.1, 2)))
  (normal(t, 0.3) + normal(t, 0.7)) / (normal(0.3, 0.3) + normal(0.3, 0.7))
}

#let halton(index, base) = {
  let fraction = 1.0
  let result = 0.0
  let k = index
  while k > 0 {
    fraction = fraction / base
    result = result + fraction * calc.rem(k, base)
    k = calc.floor(k / base)
  }
  result
}

// The curve spans x 60 to 1140, with its baseline at y 590 and its peaks at
// y 340. No ground point falls in the corner box that holds the mark.
#let curve = (x0: 60, x1: 1140, base: 590, peak: 340)
#let mark-box = (x0: 30, y0: 30, x1: 200, y1: 200)
#for i in range(1, 2600) {
  let x = halton(i, 2) * 1200
  let y = halton(i, 3) * 630
  let t = (x - curve.x0) / (curve.x1 - curve.x0)
  let under = (
    t >= 0 and t <= 1 and y <= curve.base and y >= curve.base - density(t) * (curve.base - curve.peak)
  )
  let in-mark = x >= mark-box.x0 and x <= mark-box.x1 and y >= mark-box.y0 and y <= mark-box.y1
  if under {
    place(top + left, dx: (x - 3.5) * 1pt, dy: (y - 3.5) * 1pt, circle(radius: 3.5pt, fill: gold))
  } else if not in-mark {
    place(top + left, dx: (x - 2) * 1pt, dy: (y - 2) * 1pt, circle(radius: 2pt, fill: ghost))
  }
}

// The mark without its square field, so the card points show around it.
#place(top + left, dx: 40pt, dy: 40pt, image(
  bytes(read("images/mark.svg").replace(regex("<rect[^>]*></rect>|<rect[^>]*/>"), "")),
  format: "svg",
  width: 150pt,
))

#place(top + center, dy: 50pt, stack(
  dir: ttb,
  spacing: 20pt,
  image("/_extensions/mickaelcanouilfr/assets/images/logo-paper.svg", width: 500pt),
  align(center, text(size: 30pt, style: "italic")[Biostatistician, Quarto wizard, and cinephile.]),
))
