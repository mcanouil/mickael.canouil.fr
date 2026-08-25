// Before and after for the radial coordinate system.
//
// The same plot, asking for the same 7 cm by 7 cm canvas, compiled against
// Gribouille 0.6.0 and against 0.7.0. The dashed frame is the canvas that was
// asked for, drawn at exactly that size, so the overflow is visible.
//
// A post cell cannot draw the 0.6.0 half: every cell in the post compiles
// against one version. This file imports both, and render.sh writes the light
// and the dark variant the page swaps between.
//
// Regenerate with:
//   ./render.sh
#import "@preview/gribouille:0.6.0" as g6
#import "@preview/gribouille:0.7.0" as g7

#let mode = sys.inputs.at("mode", default: "light")
#let paper = if mode == "dark" { rgb("#161616") } else { rgb("#fafafa") }
#let ink = if mode == "dark" { rgb("#f5f5f4") } else { rgb("#111827") }
#let frame = rgb("#D1495B")

#set page(width: auto, height: auto, margin: 10pt, fill: paper)
#set text(font: "Libertinus Serif", size: 10pt, fill: ink)

#let counts = (
  (day: "Monday", n: 12),
  (day: "Tuesday", n: 5),
  (day: "Wednesday", n: 18),
  (day: "Thursday", n: 42),
  (day: "Friday", n: 55),
  (day: "Saturday", n: 48),
  (day: "Sunday", n: 33),
)

#let panel(g) = g.plot(
  data: counts,
  mapping: g.aes(x: "day", y: "n", fill: "day"),
  layers: (g.geom-col(width: 0.9),),
  coord: g.coord-radial(),
  guides: g.guides(fill: none),
  labels: g.labels(x: none, y: none),
  theme: g.theme-minimal(
    ink: ink,
    paper: paper,
    text: g.element-text(size: 8pt),
  ),
  width: 7cm,
  height: 7cm,
)

#let framed(body, caption) = stack(
  dir: ttb,
  spacing: 8pt,
  box(
    width: 7cm,
    height: 7cm,
    stroke: (thickness: 0.6pt, paint: frame, dash: "dashed"),
    body,
  ),
  align(center, text(size: 9pt, weight: "bold", caption)),
)

#grid(
  columns: (8.6cm, 8.6cm),
  column-gutter: 0.4cm,
  align(center, framed(panel(g6), [0.6, 22 pt too wide])),
  align(center, framed(panel(g7), [0.7, exactly 7 cm])),
)
