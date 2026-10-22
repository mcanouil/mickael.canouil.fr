// Featured card for the Keisen 0.1.0 release post.
// Adapted from docs/assets/social/og-image.typ in mcanouil/keisen.
// Regenerate featured.png from the repository root with:
//   quarto typst compile --ppi 288 --ignore-system-fonts \
//     --font-path posts/2026-10-22-keisen-0-1/assets/_featured/fonts \
//     posts/2026-10-22-keisen-0-1/assets/_featured/featured.typ \
//     posts/2026-10-22-keisen-0-1/featured.png

#import "@preview/keisen:0.1.0": *

#let paper = rgb("#FBFBF8")
#let ink = rgb("#1A1D20")
#let muted = rgb("#585C60")
#let rule-blue = rgb("#2C5F82")
#let vermilion = rgb("#C8442F")
#let ochre-wash = rgb("#C08A2E").lighten(80%)

#set page(width: 600pt, height: 315pt, margin: 0pt, fill: paper)
#set text(font: "Libertinus Serif", fill: ink)

#place(
  left + horizon,
  dx: 36pt,
  dy: -3.5pt,
  block(width: 300pt)[
    #grid(
      columns: 2,
      column-gutter: 10pt,
      align: horizon,
      image("icon.svg", width: 44pt),
      [
        #text(size: 48pt, weight: "semibold")[Keisen]
        #text(size: 22pt, fill: muted, font: "Noto Serif JP", lang: "ja")[（罫線）]
      ],
    )
    #v(10pt)
    #text(size: 17pt)[
      Display tables for Typst,\
      built from data, not by hand.
    ]
    #v(4pt)
    #box(fill: vermilion, radius: 999pt, inset: (x: 8pt, y: 4pt))[
      #text(size: 9pt, weight: "bold", fill: paper, tracking: 0.08em)[V0.1.0 RELEASE]
    ]
    #v(4pt)
    #text(font: "DejaVu Sans Mono", size: 11pt, fill: rule-blue)[m.canouil.dev/keisen]
  ],
)

#place(
  top + left,
  dx: 335pt,
  dy: 38pt,
  rotate(-4deg, reflow: false, block(fill: white, stroke: 0.5pt + muted.lighten(60%), inset: 12pt)[
    #set text(size: 16pt)
    #display-table(
      (
        region: ("Europe", "Europe", "Asia", "Asia"),
        country: ("France", "Germany", "Japan", "Korea"),
        q1: (1204.5, 982.1, 764.0, 412.8),
        q2: (1318.0, 1045.7, 801.3, 430.1),
        q3: (1402.2, 1110.9, 857.6, 468.4),
      ),
      table-header(title: [Regional sales], subtitle: [Thousands of euros, by quarter]),
      table-stub(rowname: "country", group: "region", label: [Region]),
      columns-label(q1: [Q1], q2: [Q2], q3: [Q3]),
      format-number(("q1", "q2", "q3"), decimals: 1),
      summary-rows(functions: (Subtotal: aggregate-sum), columns: ("q1", "q2", "q3")),
      data-colour((paper, rule-blue), columns: ("q1", "q2", "q3")),
      table-style(style(text: (fill: vermilion)), locations: cells-row-groups()),
      table-style(style(fill: ochre-wash), locations: cells-summary()),
      table-footnote([Excludes intra-group sales.], locations: cells-stub(rows: 1)),
      theme: theme-booktabs(),
    )
  ]),
)

// Drawn last, so the table runs under it rather than over it.
#place(bottom, rect(width: 100%, height: 7pt, fill: vermilion))
