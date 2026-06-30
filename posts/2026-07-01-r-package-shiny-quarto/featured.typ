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

#let card(logo-block, label) = rect(
  fill: card-bg, stroke: card-stroke, radius: 7pt,
  inset: (x: 14pt, top: 18pt, bottom: 16pt),
  width: 100%,
)[
  #align(center)[
    #block(height: 40pt)[#align(center + horizon, logo-block)]
    #v(10pt)
    #text(size: 9.5pt, fill: text-muted)[#label]
  ]
]

// single-column grid; 1fr rows above and below centre the content vertically
#grid(
  columns: (1fr,),
  rows: (1fr, auto, 36pt, auto, 1fr),
  // top spacer
  [],
  // title + subtitle
  pad(x: 52pt,
    stack(spacing: 7pt,
      text(size: 40pt, weight: "bold", fill: text-main, tracking: -0.5pt)[R Package Architecture],
      text(size: 18pt, fill: accent)[S7 · targets · Shiny · Quarto],
    )
  ),
  // gap
  [],
  // logo cards
  pad(x: 52pt,
    grid(
      columns: (1fr, 1fr, 1fr, 1fr),
      column-gutter: 14pt,
      card(image("assets/r-logo.svg",      height: 40pt), "S7 object model"),
      card(image("assets/targets-hex.svg", height: 40pt), "targets pipeline"),
      card(image("assets/shiny-hex.svg",   height: 40pt), "Shiny app"),
      card(image("assets/quarto-icon.svg", height: 40pt), "Quarto extension"),
    )
  ),
  // bottom spacer
  [],
)
