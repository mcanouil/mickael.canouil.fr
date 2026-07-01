#set page(
  width: 8in,
  height: 4.2in,
  margin: 0pt,
  fill: gradient.linear(rgb("#0e091e"), rgb("#2094d5"), angle: 135deg),
)

#let accent      = white.transparentize(10%)
#let text-main   = rgb("#f8fafc")
#let text-muted  = rgb("#94a3b8")
#let card-bg     = rgb("#1e293b")
#let card-stroke = rgb("#475569") + 0.8pt
#let path-col    = rgb("#34d399")  // green for URL paths

// Star dots — great-docs space motif, concentrated on the dark (upper-left) side
#place(dx:  45pt, dy:  18pt, circle(radius: 1.8pt, fill: white.transparentize(40%)))
#place(dx: 200pt, dy:  55pt, circle(radius: 1.0pt, fill: white.transparentize(55%)))
#place(dx: 380pt, dy:  28pt, circle(radius: 0.7pt, fill: white.transparentize(35%)))
#place(dx:  90pt, dy: 120pt, circle(radius: 1.3pt, fill: white.transparentize(50%)))
#place(dx: 310pt, dy:  80pt, circle(radius: 0.9pt, fill: white.transparentize(60%)))
#place(dx: 520pt, dy:  42pt, circle(radius: 1.5pt, fill: white.transparentize(45%)))
#place(dx: 150pt, dy: 200pt, circle(radius: 0.8pt, fill: white.transparentize(55%)))
#place(dx: 460pt, dy: 140pt, circle(radius: 1.1pt, fill: white.transparentize(50%)))
#place(dx:  70pt, dy: 240pt, circle(radius: 1.4pt, fill: white.transparentize(40%)))
#place(dx: 270pt, dy: 180pt, circle(radius: 0.6pt, fill: white.transparentize(60%)))

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
      logo-card(image("assets/shiny-for-python.svg", width: 140pt), "/"),
      logo-card(image("assets/great-docs-logo.svg", height: 56pt), "/docs/"),
    )
  ),
  [],
)
