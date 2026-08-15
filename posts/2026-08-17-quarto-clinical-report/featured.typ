// Source for featured.png, the social card of the post.
// Colours are the ones of the report brand: teal, deep, amber, mist, ink, paper.
// Fonts are the ones the report bundles, so the card matches the cover page.
// Rebuild it from the post directory, with the font path of the demo repository:
//   typst compile featured.typ featured.png --ppi 192 \
//     --font-path ../../../demo/demo-quarto-clinical-report/_extensions/nordvale/clinical/fonts
// Without that path, Typst falls back to Charter and Inter.

#let teal = rgb("#0E5C63")
#let deep = rgb("#083B40")
#let amber = rgb("#C8862B")
#let mist = rgb("#E7EDEE")
#let ink = rgb("#16202A")
#let paper = rgb("#FDFDFC")

#let title-font = ("Source Serif 4", "Charter")
#let body-font = ("Source Sans 3", "Inter")

#set page(
  width: 8in,
  height: 4.2in,
  margin: 0pt,
  fill: paper,
  background: place(
    right + bottom,
    dx: -60pt,
    dy: -56pt,
    rotate(-45deg, text(
      size: 58pt,
      weight: "bold",
      fill: teal.transparentize(94%),
      font: body-font,
    )[DRAFT]),
  ),
)

#let chip(label) = box(
  fill: mist,
  radius: 4pt,
  inset: (x: 10pt, y: 7pt),
  text(size: 11pt, fill: deep, font: body-font)[#label],
)

#stack(
  block(width: 100%, height: 26pt, fill: teal, inset: (x: 40pt, y: 8pt))[
    #text(size: 9pt, fill: paper, weight: "semibold", tracking: 0.16em, font: body-font)[QUARTO · TYPST · PHARMAVERSE]
  ],
  block(inset: (x: 40pt, top: 30pt), width: 100%)[
    #text(size: 31pt, weight: "bold", fill: teal, font: title-font)[A Clinical Study Report in Quarto]
    #v(12pt)
    #line(length: 40%, stroke: 2pt + amber)
    #v(14pt)
    #text(size: 14pt, fill: ink, font: body-font)[
      Public CDISC pilot data to a branded Typst PDF and an HTML site, from one source.
    ]
    #v(20pt)
    #stack(
      dir: ltr,
      spacing: 10pt,
      chip("_brand.yml"),
      chip("Typst template"),
      chip("ICH E3 numbering"),
      chip("double programming"),
    )
  ],
)
