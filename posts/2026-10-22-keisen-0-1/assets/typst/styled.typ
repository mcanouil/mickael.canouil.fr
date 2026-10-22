// Conditional styling, data-driven colour, substitutions, and footnote marks
// numbered in reading order.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#display-table(
  (
    product: ("Bolt", "Nut", "Beam", "Plate"),
    region: ("North", "North", "South", "South"),
    units: (1250, 860, 430, 2100),
    margin: (0.182, 0.031, 0.094, none),
  ),
  table-header(title: [Regional sales], subtitle: [Financial year 2025 to 2026]),
  table-stub(rowname: "product", group: "region", label: [Product]),
  columns-label(units: [Units], margin: [Margin]),
  table-spanner([Performance], ("units", "margin")),
  format-integer("units"),
  format-percent("margin", decimals: 1),
  substitute-missing("margin", replacement: [--]),
  data-colour(("#f7fbff", "#08519c"), columns: "units"),
  table-style(
    style(text: (fill: rgb("#b2182b"), weight: "bold")),
    locations: cells-body(columns: "margin", rows: row => row.margin != none and row.margin < 0.05),
  ),
  table-footnote([Excludes intra-group sales.], locations: cells-column-labels(columns: "units")),
  table-footnote([Margin was not reported.], locations: cells-body(columns: "margin", rows: 3)),
  table-source-note([Source: internal ledger.]),
)
