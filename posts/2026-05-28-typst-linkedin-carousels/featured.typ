// Featured / social card for the "Build LinkedIn Carousels with Typst" post.
// Social-card aspect (~1.91:1, rasterises to ~1200x630). Dogfoods the rail
// motif from the slide layout taught in the post.

#set document(title: "Build LinkedIn Carousels with Typst", author: "Mickaël Canouil")
#set text(lang: "en")
#set page(width: 24cm, height: 12.6cm, margin: 0cm)

#let paper = rgb("#f4f6f5")
#let paper-2 = rgb("#e7ece9")
#let ink = rgb("#0f1f1c")
#let ink-soft = rgb("#5a6b66")
#let accent = rgb("#1f9d72")

#let display = "Libertinus Serif"
#let body = "Libertinus Serif"
#let mono = "DejaVu Sans Mono"
#set text(font: body, fill: ink)

#let kicker(t) = grid(
  columns: (0.8cm, auto),
  column-gutter: 0.35cm,
  align: horizon,
  line(length: 0.8cm, stroke: 2pt + accent),
  text(font: mono, size: 13pt, weight: "medium", fill: ink-soft, tracking: 1.5pt, upper(t)),
)

#page(fill: paper, {
  // full-height accent rail on the left edge
  place(left + top, rect(width: 0.55cm, height: 100%, fill: accent))

  // stacked card edges as a background motif, bottom-right
  place(bottom + right, dx: 1.0cm, dy: 1.0cm, rect(width: 5.5cm, height: 5.5cm, radius: 12pt, fill: paper-2))
  place(bottom + right, dx: 0.3cm, dy: 0.3cm, rect(width: 5.5cm, height: 5.5cm, radius: 12pt, stroke: 1.5pt + ink-soft))
  place(bottom + right, dx: -0.4cm, dy: -0.4cm, rect(
    width: 5.5cm,
    height: 5.5cm,
    radius: 12pt,
    fill: paper,
    stroke: 2pt + accent,
  ))

  block(width: 100%, height: 100%, inset: (left: 2.4cm, right: 1.7cm, y: 1.4cm), {
    kicker("Typst · Tutorial")
    v(1fr)
    block(width: 16cm, {
      text(font: display, size: 42pt, weight: "bold", fill: ink, tracking: -1pt, "Build LinkedIn")
      linebreak()
      text(font: display, size: 42pt, weight: "bold", fill: ink, tracking: -1pt, "Carousels with ")
      text(font: display, size: 42pt, weight: "bold", fill: accent, tracking: -1pt, "Typst")
      v(0.45cm)
      text(font: display, size: 24pt, weight: "medium", fill: ink-soft, "The ")
      text(font: display, size: 24pt, weight: "medium", fill: accent, "Slide")
      text(font: display, size: 24pt, weight: "medium", fill: ink-soft, " Layout")
    })
    v(1fr)
    grid(
      columns: (auto, auto, auto),
      column-gutter: 0.5cm,
      align: horizon,
      text(font: mono, size: 20pt, fill: ink-soft, weight: "bold", ".typ"),
      text(font: mono, size: 17pt, fill: accent, "──▶"),
      text(font: mono, size: 20pt, fill: accent, weight: "bold", ".pdf"),
    )
  })
})
