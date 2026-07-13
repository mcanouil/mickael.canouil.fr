// Source for hero-light.svg, the four-panel figure on the featured card.
// Regenerate with:
//   typst compile _hero.typ hero-light.svg
// then rebuild featured.png with:
//   node screenshot.mjs
#import "@preview/gribouille:0.5.0": *
#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let cb = (rgb("#0072B2"), rgb("#D55E00"), rgb("#009E73"), rgb("#E69F00"))
#let paper = rgb("#FFFDF7")
#let bare = theme-void(paper: paper)

#let stripes = tiling(size: (6pt, 6pt))[
  #place(rect(width: 100%, height: 100%, fill: cb.at(0).lighten(55%)))
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 1pt + cb.at(0)))
]
#let dots = tiling(size: (7pt, 7pt))[
  #place(rect(width: 100%, height: 100%, fill: cb.at(1).lighten(55%)))
  #place(dx: 2pt, dy: 2pt, circle(radius: 1.4pt, fill: cb.at(1)))
]
#let cross = tiling(size: (7pt, 7pt))[
  #place(rect(width: 100%, height: 100%, fill: cb.at(2).lighten(55%)))
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.8pt + cb.at(2)))
  #place(line(start: (0%, 0%), end: (100%, 100%), stroke: 0.8pt + cb.at(2)))
]

#let psorted = penguins.sorted(key: r => r.species)

#let stream-data = ()
#for g in ("A", "B", "C", "D") {
  let peak = (A: 8, B: 20, C: 12, D: 4).at(g)
  for x in range(0, 21) {
    stream-data.push((x: x, y: 2 + 4 * calc.exp(-0.02 * calc.pow(x - peak, 2)), grp: g))
  }
}

#let standings = (
  (t: 1, rank: 1, team: "A"), (t: 2, rank: 3, team: "A"), (t: 3, rank: 2, team: "A"), (t: 4, rank: 1, team: "A"),
  (t: 1, rank: 2, team: "B"), (t: 2, rank: 1, team: "B"), (t: 3, rank: 1, team: "B"), (t: 4, rank: 2, team: "B"),
  (t: 1, rank: 3, team: "C"), (t: 2, rank: 2, team: "C"), (t: 3, rank: 4, team: "C"), (t: 4, rank: 3, team: "C"),
  (t: 1, rank: 4, team: "D"), (t: 2, rank: 4, team: "D"), (t: 3, rank: 3, team: "D"), (t: 4, rank: 4, team: "D"),
)

#compose(
  // 1. Ridgeline with pattern fills.
  defer(
    plot,
    data: penguins,
    mapping: aes(x: "body-mass", y: "species", fill: "species"),
    layers: (geom-density-ridges(scale: 1.6, stroke: 0.7pt),),
    scales: scales(y: scale-discrete(expand: (auto, 55%)), fill: scale-manual(values: (stripes, dots, cross))),
    labels: labels(x: none, y: none),
    guides: guides(fill: none),
    theme: bare,
  ),
  // 2. Violin + beeswarm: filled points, thin outline.
  defer(
    plot,
    data: psorted,
    mapping: aes(x: "species", y: "body-mass", fill: "species"),
    layers: (
      geom-violin(scale: "width", trim: false, alpha: 0.4),
      geom-beeswarm(mapping: aes(x: as-factor("species")), size: 1.8pt, colour: white, stroke: 0.35pt, alpha: 0.95),
    ),
    scales: scales(fill: scale-manual(values: cb)),
    labels: labels(x: none, y: none),
    guides: guides(fill: none),
    theme: bare,
  ),
  // 3. Streamgraph.
  defer(
    plot,
    data: stream-data,
    mapping: aes(x: "x", y: "y", fill: "grp"),
    layers: (geom-area(position: position-stack(offset: "silhouette")),),
    scales: scales(fill: scale-manual(values: cb)),
    labels: labels(x: none, y: none),
    guides: guides(fill: none),
    theme: bare,
  ),
  // 4. Bump chart with filled points.
  defer(
    plot,
    data: standings,
    mapping: aes(x: "t", y: "rank", colour: "team", fill: "team"),
    layers: (
      geom-line(stat: stat-connect(connection: "sigmoid"), linewidth: 1.5pt),
      geom-point(size: 4pt, stroke: none),
    ),
    scales: scales(y: scale-reverse(), colour: scale-manual(values: cb), fill: scale-manual(values: cb)),
    labels: labels(x: none, y: none),
    guides: guides(colour: none, fill: none),
    theme: bare,
  ),
  columns: 2,
  gutter: 0.6cm,
  width: 15cm,
  height: 11cm,
)
