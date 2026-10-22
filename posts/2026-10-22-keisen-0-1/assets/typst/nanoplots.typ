// In-cell nanoplots drawn with native primitives, sharing one domain down the
// column so the sparklines can be compared. Cash must read as flat: scaled per
// cell, its small wobble would draw exactly like real movement.
//
// A plot is taller than the figures beside it. The theme's
// `cell-vertical-align` places the shorter cells in each row.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let trends = (
  (1.0, 1.2, 1.1, 1.4, 1.8, 2.1),
  (2.0, 1.8, 1.6, 1.5, 1.2, 0.9),
  (1.5, 1.5, 1.6, 1.5, 1.7, 1.6),
)

#display-table(
  (
    asset: ("Equities", "Bonds", "Cash"),
    trend: trends,
    volume: trends,
    weight: (0.62, 0.31, 0.07),
  ),
  table-header(title: [Portfolio], subtitle: [Twelve-month trends]),
  table-stub(rowname: "asset", label: [Asset]),
  columns-label(trend: [Trend], volume: [Volume], weight: [Weight]),
  format-nanoplot("trend", plot: nanoplot-line, width: 6em, height: 1em, baseline: 25%),
  format-nanoplot("volume", plot: nanoplot-bar, width: 6em, height: 1em, baseline: 25%),
  format-percent("weight", decimals: 1),
  table-options(cell-vertical-align: horizon),
  table-source-note([Source: portfolio ledger.]),
)
