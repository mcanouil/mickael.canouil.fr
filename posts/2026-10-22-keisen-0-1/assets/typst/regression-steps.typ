// The regression table of the post, split into the steps the post builds it in.
// Adapted from tests/visual/gallery-regression-keisen.typ in mcanouil/keisen.

#import "@preview/keisen:0.1.0": *

#let data = (
  term: (
    "Treatment",
    "Age, per 10 years",
    "Female",
    "Body mass index",
    "Current smoker",
  ),
  crude: (-0.42, 0.18, -0.05, 0.09, 0.21),
  crude-lower: (-0.61, 0.07, -0.24, 0.04, -0.02),
  crude-upper: (-0.23, 0.29, 0.14, 0.14, 0.44),
  crude-p: (0.000021, 0.0012, 0.61, 0.00034, 0.074),
  adjusted: (-0.39, 0.15, -0.02, 0.07, 0.12),
  adjusted-lower: (-0.57, 0.04, -0.20, 0.02, -0.10),
  adjusted-upper: (-0.21, 0.26, 0.16, 0.12, 0.34),
  adjusted-p: (0.000038, 0.0081, 0.83, 0.0049, 0.29),
)

#let header = (
  table-header(
    title: [Change in HbA1c at 26 weeks],
    subtitle: [Linear regression, percentage points],
  ),
)

#let stub = (
  table-stub(rowname: "term", label: [Term]),
)

#let numbers = (
  format-number(
    name => name != "term" and not name.ends-with("-p"),
    decimals: 2,
  ),
  format-number(name => name.ends-with("-p"), decimals: 3),
  format("crude-p", value => [< 0.001], rows: row => row.crude-p < 0.001),
  format("adjusted-p", value => [< 0.001], rows: row => row.adjusted-p < 0.001),
)

#let columns = (
  columns-combine(
    "crude-interval",
    ("crude-lower", "crude-upper"),
    (low, high) => [#low, #high],
    label: [95% CI],
  ),
  columns-combine(
    "adjusted-interval",
    ("adjusted-lower", "adjusted-upper"),
    (low, high) => [#low, #high],
    label: [95% CI],
  ),
  columns-label(
    crude: [Estimate],
    crude-p: [_p_],
    adjusted: [Estimate],
    adjusted-p: [_p_],
  ),
  table-spanner([Unadjusted], ("crude", "crude-interval", "crude-p")),
  table-spanner([Adjusted], ("adjusted", "adjusted-interval", "adjusted-p")),
)

#let emphasis = (
  table-style(
    style(text: (weight: "bold")),
    locations: cells-body(
      columns: ("adjusted", "adjusted-interval", "adjusted-p"),
      rows: row => row.adjusted-p < 0.05,
    ),
  ),
)

#let notes = (
  table-footnote(
    [Adjusted for every other term in the table.],
    locations: cells-column-spanners(spanners: [Adjusted]),
  ),
  table-source-note([Source: synthetic trial data.]),
)

// Shades the cells a step changes. Used only by the renders, never shown.
#let changed(..locations) = locations.pos().map(location => table-style(
  style(fill: rgb("#fff1a8")),
  locations: location,
))
