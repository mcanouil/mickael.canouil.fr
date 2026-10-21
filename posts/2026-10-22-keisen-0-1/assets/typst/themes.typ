// One small table drawn in each of the four themes that ship with Keisen.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let fuel(theme, name) = display-table(
  (
    model: ("Audi A4", "BMW 320i", "VW Golf"),
    consumption: (7.25, 8.5, 6.125),
  ),
  table-header(title: name),
  columns-label(model: [Model], consumption: [L/100 km]),
  format-number("consumption", decimals: 2),
  theme: theme,
)

#grid(
  columns: 2,
  gutter: 1.5em,
  fuel(theme-default(), [`theme-default()`]),
  fuel(theme-booktabs(), [`theme-booktabs()`]),
  fuel(theme-compact(), [`theme-compact()`]),
  fuel(theme-minimal(), [`theme-minimal()`]),
)
