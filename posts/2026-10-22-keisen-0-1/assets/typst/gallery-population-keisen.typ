// Gallery: population by region, built with Keisen.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let data = (
  region: (
    "North East",
    "North West",
    "Yorkshire and The Humber",
    "East Midlands",
    "West Midlands",
    "East",
    "London",
    "South East",
    "South West",
  ),
  population: (
    2683040,
    7516113,
    5541262,
    4934939,
    6021653,
    6398497,
    8945309,
    9379833,
    5764881,
  ),
  share: (0.047, 0.131, 0.097, 0.086, 0.105, 0.112, 0.156, 0.164, 0.101),
  profile: (
    (0.17, 0.12, 0.24, 0.27, 0.20),
    (0.18, 0.12, 0.26, 0.26, 0.18),
    (0.19, 0.12, 0.25, 0.25, 0.19),
    (0.18, 0.11, 0.25, 0.26, 0.20),
    (0.19, 0.12, 0.26, 0.25, 0.18),
    (0.18, 0.10, 0.25, 0.27, 0.20),
    (0.20, 0.14, 0.36, 0.20, 0.10),
    (0.18, 0.11, 0.25, 0.27, 0.19),
    (0.16, 0.10, 0.23, 0.28, 0.23),
  ),
  median-age: (42.3, 40.1, 40.4, 41.2, 39.8, 42.0, 35.6, 41.8, 44.5),
)

#display-table(
  data,
  table-header(
    title: [Population by region],
    subtitle: [Mid-year estimates, 2025],
  ),
  table-stub(rowname: "region", label: [Region]),
  columns-label(
    population: [Population],
    share: [Share of England],
    profile: [Age profile],
    median-age: [Median age],
  ),
  format-integer("population"),
  format-percent("share", decimals: 1),
  format-number("median-age", decimals: 1),
  format-nanoplot(
    "profile",
    plot: nanoplot-bar,
    width: 5em,
    height: 1em,
    baseline: 25%,
  ),
  grand-summary-rows(functions: (Total: aggregate-sum), columns: (
    "population",
  )),
  table-footnote(
    [Bands: 0 to 15, 16 to 24, 25 to 44, 45 to 64, 65 and over.],
    locations: cells-column-labels(columns: "profile"),
  ),
  table-source-note([Source: synthetic census data.]),
  table-options(cell-vertical-align: horizon),
)
