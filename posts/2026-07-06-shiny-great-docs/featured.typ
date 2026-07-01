#set page(
  width: 8in,
  height: 4.2in,
  margin: 0pt,
  fill: rgb("#0f172a"),
)

#let accent     = rgb("#7dd3fc")
#let text-main  = rgb("#f8fafc")
#let text-muted = rgb("#94a3b8")
#let card-bg    = rgb("#1e293b")
#let card-stroke = rgb("#475569") + 0.8pt
#let path-col   = rgb("#34d399")  // green for URL paths

#let logo-card(logo-block, path) = rect(
  fill: card-bg, stroke: card-stroke, radius: 7pt,
  inset: (x: 28pt, top: 22pt, bottom: 20pt),
  width: 100%,
)[
  #align(center)[
    #block(height: 56pt)[#align(center + horizon, logo-block)]
    #v(10pt)
    #text(size: 12pt, fill: path-col, font: "Menlo")[#path]
  ]
]

// single-column grid; 1fr rows enforce vertical centering
#grid(
  columns: (1fr,),
  rows: (1fr, auto, 28pt, auto, 1fr),
  [],
  pad(x: 60pt,
    stack(spacing: 8pt,
      text(size: 42pt, weight: "bold", fill: text-main, tracking: -0.5pt)[One URL. One Process.],
      text(size: 19pt, fill: accent)[Shiny for Python + great-docs, served together],
    )
  ),
  [],
  pad(x: 60pt,
    grid(
      columns: (1fr, 1fr),
      column-gutter: 20pt,
      logo-card(image("assets/shiny-hex.svg",   height: 56pt), "/"),
      logo-card(image("assets/quarto-icon.svg", height: 56pt), "/docs/"),
    )
  ),
  [],
)
