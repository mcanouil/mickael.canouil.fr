// Gallery: income statement, built with Keisen.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let data = (
  section: ("Revenue",) * 3 + ("Operating costs",) * 4,
  line: (
    "Product sales",
    "Services",
    "Licensing",
    "Cost of sales",
    "Staff",
    "Premises",
    "Marketing",
  ),
  fy2025: (4820000, 1310000, 245000, -2410000, -1870000, -390000, -265000),
  fy2026: (5340000, 1480000, 228000, -2650000, -1990000, -405000, -310000),
)

#display-table(
  data,
  table-header(title: [Income statement], subtitle: [Years ending 31 March]),
  table-stub(rowname: "line", group: "section", label: [Line]),
  columns-label(fy2025: [2025], fy2026: [2026]),
  table-spanner([Pounds sterling], ("fy2025", "fy2026")),
  format-currency(("fy2025", "fy2026"), currency: "GBP", decimals: 0),
  summary-rows(functions: (Subtotal: aggregate-sum), columns: (
    "fy2025",
    "fy2026",
  )),
  grand-summary-rows(functions: ("Operating profit": aggregate-sum), columns: (
    "fy2025",
    "fy2026",
  )),
  table-style(style(fill: luma(240)), locations: cells-grand-summary()),
  table-source-note([Source: synthetic accounts.]),
  theme: theme-booktabs(),
)
