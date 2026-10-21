// Gallery: league standings, built with Keisen.
// Its native twin is gallery-standings-native.typ; the two render alike.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let data = (
  position: (1, 2, 3, 4, 5, 6, 7, 8),
  team: (
    "Ashford",
    "Brampton",
    "Carrow",
    "Dunmore",
    "Elwick",
    "Fenwick",
    "Garth",
    "Hollins",
  ),
  played: (14,) * 8,
  won: (10, 9, 7, 6, 5, 4, 3, 2),
  drawn: (2, 2, 3, 2, 3, 2, 3, 3),
  lost: (2, 3, 4, 6, 6, 8, 8, 9),
  difference: (18, 14, 6, 2, -1, -8, -12, -19),
  points: (32, 29, 24, 20, 18, 14, 12, 9),
  form: (
    (3, 3, 1, 3, 3),
    (3, 1, 3, 3, 0),
    (1, 3, 0, 3, 1),
    (0, 3, 3, 0, 1),
    (1, 0, 3, 1, 0),
    (0, 0, 3, 1, 0),
    (1, 0, 0, 3, 0),
    (0, 1, 0, 0, 0),
  ),
)

#display-table(
  data,
  table-header(title: [League table], subtitle: [After 14 rounds]),
  columns-label(
    position: [],
    team: [Team],
    played: [P],
    won: [W],
    drawn: [D],
    lost: [L],
    difference: [GD],
    points: [Pts],
    form: [Last five],
  ),
  format-integer("difference", sign: true),
  format-nanoplot(
    "form",
    plot: nanoplot-points,
    width: 4em,
    height: 0.8em,
    domain: (0, 3),
  ),
  table-style(style(fill: rgb("#e5f5e0")), locations: cells-body(rows: (0, 1))),
  table-style(style(fill: rgb("#fee0d2")), locations: cells-body(rows: (7,))),
  data-colour(
    ("#ef8a62", "#f7f7f7", "#67a9cf"),
    columns: "difference",
    domain: (-20, 20),
  ),
  table-source-note([Top two promoted; bottom team relegated.]),
)
