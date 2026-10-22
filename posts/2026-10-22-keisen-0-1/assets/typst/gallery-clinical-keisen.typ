// Gallery: baseline characteristics, built with Keisen.
// Its native twin is gallery-clinical-native.typ; the two render alike.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let data = (
  section: ("Demographics",) * 4 + ("Disease history",) * 4,
  characteristic: (
    "Age, years",
    "Female",
    "Body mass index, kg/m²",
    "Current smoker",
    "HbA1c, %",
    "Diabetes duration, years",
    "Prior myocardial infarction",
    "Hypertension",
  ),
  kind: ("mean", "count", "mean", "count", "mean", "mean", "count", "count"),
  drug: (61.4, 54, 29.8, 22, 8.1, 9.6, 14, 81),
  drug-spread: (9.2, 45.0, 4.7, 18.3, 0.9, 6.1, 11.7, 67.5),
  placebo: (60.9, 57, 30.2, 19, 8.2, 10.1, 12, 77),
  placebo-spread: (9.8, 48.3, 5.1, 16.1, 1.0, 6.4, 10.2, 65.3),
)

#display-table(
  data,
  table-header(
    title: [Baseline characteristics],
    subtitle: [Randomised population, by treatment arm],
  ),
  table-stub(
    rowname: "characteristic",
    group: "section",
    label: [Characteristic],
  ),
  columns-hide("kind"),
  format-number(
    ("drug", "placebo"),
    rows: row => row.kind == "mean",
    decimals: 1,
  ),
  format-integer(("drug", "placebo"), rows: row => row.kind == "count"),
  format-number(("drug-spread", "placebo-spread"), decimals: 1),
  columns-combine(
    "drug-arm",
    ("drug", "drug-spread"),
    (value, spread) => [#value (#spread)],
    label: [Drug \ _n_ = 120],
  ),
  columns-combine(
    "placebo-arm",
    ("placebo", "placebo-spread"),
    (value, spread) => [#value (#spread)],
    label: [Placebo \ _n_ = 118],
  ),
  table-spanner([Treatment arm], ("drug-arm", "placebo-arm")),
  table-footnote(
    [Mean (SD) for continuous variables; _n_ (%) for categorical variables.],
    locations: cells-column-spanners(),
  ),
  table-source-note([Source: synthetic trial data.]),
  theme: theme-booktabs(),
)
