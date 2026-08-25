// Source for hero-light.svg, the three-panel figure on the featured card.
// Each panel shows one of the 0.7.0 changes: a brand file becoming a themed
// plot, arrowheads on the line geoms, and a plot small enough to sit in prose.
// Regenerate with:
//   typst compile _hero.typ hero-light.svg
// then rebuild featured.png with:
//   node screenshot.mjs
#import "@preview/gribouille:0.7.0": *
#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let paper = rgb("#FFFDF7")
#let ink = rgb("#1A1A1A")
#let gold = rgb("#B5830A")
#let teal = rgb("#1F7A8C")
#let red = rgb("#E94C3D")

// Row 1, left: the brand file, as few lines as carry the point. The same brand
// the post's first figure uses, so the card and the post agree.
#let brand = (
  color: (
    foreground: "#0B2545",
    background: "#E7EEF6",
    primary: "#D1495B",
    secondary: "#00798C",
    tertiary: "#EDAE49",
  ),
)

#let brand-source = block(
  inset: (x: 7pt, y: 5pt),
  radius: 3pt,
  stroke: 0.4pt + ink.lighten(65%),
  fill: ink.lighten(94%),
  text(size: 7.5pt, font: "DejaVu Sans Mono", ink)[
    #set par(leading: 4pt)
    #set align(left)
    color: \
    #h(6pt)foreground: "\#0B2545" \
    #h(6pt)background: "\#E7EEF6" \
    #h(6pt)primary: "\#D1495B" \
    #h(6pt)secondary: "\#00798C" \
    #h(6pt)tertiary: "\#EDAE49"
  ],
)

// Row 1, right: the same brand, drawn.
#let branded = plot(
  data: penguins,
  mapping: aes(x: "flipper-len", y: "body-mass", fill: "species"),
  layers: (geom-point(size: 1.4pt, alpha: 0.85, stroke: none),),
  labels: labels(x: none, y: none),
  guides: guides(fill: none),
  theme: theme-brand(brand, text: element-text(size: 7pt)),
  width: 6.6cm,
  height: 3cm,
)

#let brand-panel = align(
  center + horizon,
  stack(
    dir: ltr,
    spacing: 10pt,
    align(horizon, brand-source),
    align(horizon, stack(
      dir: ttb,
      spacing: 3pt,
      text(size: 9pt, weight: "bold", ink)[`theme-brand()`],
      text(size: 14pt, fill: gold, sym.arrow.r),
    )),
    align(horizon, branded),
  ),
)

// Row 2, left: arrowheads, one open head on the series and one double-headed
// span underneath it.
#let arrows = plot(
  data: economics,
  mapping: aes(x: "date", y: "unemploy"),
  layers: (
    geom-line(
      linewidth: 1.2pt,
      colour: teal,
      arrow: arrow(length: 8pt, angle: 20deg),
    ),
    geom-segment(
      data: ((x: "2008-01-01", y: 6900, xend: "2009-10-01", yend: 6900),),
      mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend"),
      colour: gold,
      linewidth: 0.9pt,
      arrow: arrow(length: 6pt, ends: "both", type: "closed"),
    ),
  ),
  scales: scales(x: scale-date(date-format: "[year]-[month repr:numerical]")),
  labels: labels(x: none, y: none),
  theme: theme-minimal(
    paper: paper,
    ink: ink,
    text: element-text(size: 7.5pt),
  ),
  width: 7.1cm,
  height: 4.8cm,
)

// Row 2, right: a plot small enough to sit in a line of prose.
#let spark(column, colour) = plot(
  data: economics,
  mapping: aes(x: "date", y: column),
  layers: (geom-line(linewidth: 0.9pt, colour: colour),),
  scales: scales(x: scale-date()),
  theme: theme-void(paper: paper, ink: ink),
  width: 2.2cm,
  height: 0.7cm,
)

#let inline-panel = block(
  width: 7.1cm,
  inset: (x: 12pt, y: 16pt),
  radius: 3pt,
  stroke: 0.4pt + ink.lighten(65%),
  fill: paper,
  text(size: 9.8pt, font: "Libertinus Serif", ink)[
    #set par(leading: 12pt)
    Unemployment #box(baseline: 30%, spark("unemploy", teal)) rose for most of
    the window, while the savings rate #box(baseline: 30%, spark("psavert", red))
    peaked and eased back.
  ],
)

#grid(
  columns: (7.4cm, 7.4cm),
  rows: (3.2cm, 5.4cm),
  column-gutter: 0.6cm,
  row-gutter: 0.5cm,
  grid.cell(colspan: 2, brand-panel),
  align(center + horizon, arrows),
  align(center + horizon, inline-panel),
)
