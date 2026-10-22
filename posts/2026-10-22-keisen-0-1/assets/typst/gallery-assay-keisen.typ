// Gallery: laboratory assay, built with Keisen.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let data = (
  sample: ("W-01", "W-02", "W-03", "W-04", "W-05", "W-06", "W-07", "W-08"),
  lead: (2.31, 11.84, 0.87, 4.52, 15.06, 1.12, 3.98, 7.45),
  lead-error: (0.12, 0.41, 0.09, 0.18, 0.55, 0.10, 0.16, 0.27),
  cadmium: (0.42, 1.08, none, 0.35, 2.71, none, 0.29, 0.66),
  activity: (
    0.0000124,
    0.0000873,
    0.0000031,
    0.0000215,
    0.000142,
    0.0000048,
    0.0000187,
    0.0000552,
  ),
)

#display-table(
  data,
  table-header(
    title: [Drinking water assay],
    subtitle: [Eight sites, March 2026],
  ),
  table-stub(rowname: "sample", label: [Sample]),
  format-number(("lead", "lead-error", "cadmium"), decimals: 2),
  format-scientific("activity", decimals: 2),
  substitute-missing("cadmium", replacement: [n.d.]),
  columns-combine(
    "lead-result",
    ("lead", "lead-error"),
    (value, error) => [#value ± #error],
    label: [Lead (µg/L)],
  ),
  columns-label(cadmium: [Cadmium (µg/L)], activity: [Gross alpha (Bq/L)]),
  table-style(
    style(text: (fill: rgb("#b2182b"), weight: "bold")),
    locations: cells-body(columns: "lead-result", rows: row => row.lead > 10),
  ),
  table-footnote(
    [Values in bold red are above the regulatory limit of 10 µg/L.],
    locations: cells-column-labels(columns: "lead-result"),
  ),
  table-footnote(
    [n.d.: not detected.],
    locations: cells-column-labels(columns: "cadmium"),
  ),
  table-source-note([Source: synthetic laboratory data.]),
  theme: theme-booktabs(),
)
