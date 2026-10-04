// Source for featured.png, the social card of the post.
// One extension manifest on the left fans out to many sites on the right.
// Colours come from `_extensions/mickaelcanouilfr/scss/_defaults.scss`, the site palette.
// Rebuild it from the post directory:
//   typst compile featured.typ featured.png --ppi 192

#let ink = rgb("#111827")
#let gold = rgb("#b5830a")
#let rule = rgb("#d1c4a0")
#let paper = rgb("#fafafa")
#let paper-warm = rgb("#f7f4ec")

#let title-font = ("Source Serif 4", "Charter")
#let body-font = ("Source Sans 3", "Inter")
#let mono-font = ("JetBrains Mono", "DejaVu Sans Mono")

#let page-w = 8in

#set page(width: page-w, height: 4.2in, margin: 0pt, fill: paper)

#let tile-w = 72pt
#let tile-h = 32pt
#let gap-x = 12pt
#let gap-y = 9pt
#let grid-x = page-w - 40pt - 4 * tile-w - 3 * gap-x
#let grid-y = 168pt
#let box-x = 40pt
#let box-w = 150pt
#let box-h = 74pt
#let box-y = grid-y + (3 * tile-h + 2 * gap-y - box-h) / 2

#let site-tile = box(
  width: tile-w,
  height: tile-h,
  fill: paper-warm,
  radius: 4pt,
  stroke: 0.6pt + rule,
  clip: true,
)[
  #place(top, block(width: 100%, height: 5pt, fill: ink))
  #align(center + horizon, text(size: 7pt, fill: ink, font: mono-font)[type: atelier])
]

#for row in range(3) {
  let y = grid-y + row * (tile-h + gap-y)
  place(top + left, line(
    start: (box-x + box-w, box-y + box-h / 2),
    end: (grid-x, y + tile-h / 2),
    stroke: 1pt + gold,
  ))
  for col in range(4) {
    let x = grid-x + col * (tile-w + gap-x)
    place(top + left, dx: x, dy: y, site-tile)
  }
}

#place(top + left, dx: box-x, dy: box-y, box(
  width: box-w,
  height: box-h,
  fill: ink,
  radius: 6pt,
  inset: 12pt,
)[
  #text(size: 12pt, fill: paper, weight: "bold", font: mono-font)[\_extension.yml]
  #v(2pt)
  #text(size: 9pt, fill: rule, font: mono-font)[contributes:\ #h(1em)project: ...]
])

#block(width: 100%, height: 26pt, fill: ink, inset: (x: 40pt, y: 8pt))[
  #text(size: 9pt, fill: rule, weight: "semibold", tracking: 0.16em, font: body-font)[QUARTO · PROJECT TYPES]
]

#block(inset: (x: 40pt, top: 18pt), width: 100%)[
  #text(size: 24pt, weight: "bold", fill: ink, font: title-font)[An Extension Can Ship a Whole Quarto Project Type]
  #v(4pt)
  #line(length: 30%, stroke: 2pt + gold)
]
