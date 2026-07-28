// Source for hero-light.svg, the three-panel figure on the featured card.
// Each panel shows one of the 0.6.0 changes: the wrangling verbs across the
// first row, then quantile-placed breaks and the new element-tick lengths.
// Regenerate with:
//   typst compile _hero.typ hero-light.svg
// then rebuild featured.png with:
//   node screenshot.mjs
#import "@preview/gribouille:0.6.0": *
#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let cb = (rgb("#0072B2"), rgb("#D55E00"), rgb("#009E73"), rgb("#E69F00"))
#let paper = rgb("#FFFDF7")
#let ink = rgb("#1A1A1A")

#let by-class = summarise(
  mpg,
  mean-hwy: rows => rows.map(row => row.hwy).sum() / rows.len(),
  by: "class",
).sorted(key: row => row.mean-hwy)

#let kind = (
  (class: "compact", kind: "Car"),
  (class: "subcompact", kind: "Car"),
  (class: "midsize", kind: "Car"),
  (class: "2seater", kind: "Car"),
  (class: "minivan", kind: "Van"),
  (class: "suv", kind: "SUV"),
  (class: "pickup", kind: "Truck"),
)
#let enriched = left-join(by-class, kind, by: "class")

// Row 1: the wrangling verbs, shown as the rows going in and coming out.
#let cell(body, weight: "regular") = text(size: 9pt, weight: weight, body)

#let sheet(head, rows) = table(
  columns: head.len(),
  inset: (x: 5pt, y: 3pt),
  stroke: 0.4pt + ink.lighten(65%),
  fill: (_, row) => if row == 0 { ink.lighten(92%) } else { paper },
  align: (col, _) => if col == 0 { left } else { right },
  ..head.map(h => cell(weight: "bold", h)),
  ..rows.flatten().map(c => cell(c)),
)

// Both tables are the real rows: the raw ones going in, the aggregated and
// joined ones coming out, so the card cannot drift from what the code returns.
#let picked = ("compact", "suv", "pickup")

#let raw = sheet(
  ("class", "hwy"),
  mpg
    .filter(row => row.class in picked)
    .slice(0, 5)
    .map(row => (row.class, str(row.hwy))),
)

#let out = sheet(
  ("class", "mean-hwy", "kind"),
  enriched
    .filter(row => row.class in picked)
    .map(row => (
      row.class,
      str(calc.round(row.mean-hwy, digits: 1)),
      row.kind,
    )),
)

#let pipeline = align(
  center + horizon,
  stack(
    dir: ltr,
    spacing: 10pt,
    align(horizon, raw),
    align(horizon, stack(
      dir: ttb,
      spacing: 3pt,
      cell(weight: "bold", `summarise()`),
      cell(weight: "bold", `left-join()`),
      text(size: 14pt, fill: cb.at(1), sym.arrow.r),
    )),
    align(horizon, out),
  ),
)

// Row 2, left: breaks at the quartiles of the series, labels kept so the uneven
// spacing is readable.
#let breaks = plot(
  data: economics,
  mapping: aes(x: "date", y: "unemploy"),
  layers: (
    geom-line(colour: cb.at(0), linewidth: 1.2pt),
    geom-point(size: 1.6pt, fill: cb.at(0), stroke: none),
  ),
  scales: scales(
    x: scale-date(),
    y: scale-continuous(
      breaks: breaks-quantile(),
      labels: format-comma(digits: 0),
    ),
  ),
  labels: labels(x: none, y: none),
  theme: theme-minimal(
    paper: paper,
    ink: ink,
    text: element-text(size: 7.5pt),
    axis-text-x: element-blank(),
  ),
  width: 7.1cm,
  height: 5.8cm,
)

// Row 2, right: long major marks on x, half-length on y, duplicated axis on the
// right carrying its marks without labels.
#let ticks = plot(
  data: penguins,
  mapping: aes(x: "flipper-len", y: "body-mass", fill: "species"),
  layers: (geom-point(size: 1.6pt, alpha: 0.8, stroke: none),),
  scales: scales(
    y: scale-continuous(secondary: dup-axis()),
    fill: scale-manual(values: cb),
  ),
  labels: labels(x: none, y: none),
  guides: guides(fill: none),
  theme: theme-minimal(
    paper: paper,
    ink: ink,
    text: element-text(size: 7.5pt),
    axis-line: element-line(stroke: 0.6pt),
    axis-ticks: element-tick(length: 0.3cm, stroke: 0.9pt),
    axis-ticks-y: element-tick(length: 50%),
    axis-text-y-right: element-blank(),
    panel-grid: element-blank(),
  ),
  width: 7.1cm,
  height: 5.8cm,
)

#grid(
  columns: (7.4cm, 7.4cm),
  rows: (3cm, 6.4cm),
  column-gutter: 0.6cm,
  row-gutter: 0.5cm,
  grid.cell(colspan: 2, align(center + horizon, pipeline)),
  align(center + horizon, breaks),
  align(center + horizon, ticks),
)
