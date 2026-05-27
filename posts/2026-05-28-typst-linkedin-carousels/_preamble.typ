#set document(author: "Mickaël Canouil")
#set text(lang: "en")
#set page(width: 24cm, height: 18cm, margin: 0cm)

// ── palette ──────────────────────────────────────────────────────────────
#let paper = rgb("#f4f6f5")
#let ink = rgb("#0f1f1c")
#let ink-soft = rgb("#5a6b66")
#let accent = rgb("#1f9d72")

// ── fonts (Typst built-ins, identical on every machine and in CI) ──────────
#let display = "Libertinus Serif"
#let body = "Libertinus Serif"
#let mono = "DejaVu Sans Mono"
#set text(font: body, fill: ink, size: 19pt)

// ── the slide layout taught in the post ────────────────────────────────────
// A full-height accent rail on the left edge and an optional page index,
// stamped on every page; content sits in an inset cleared past the rail.
#let slide(index: none, fill: paper, body) = page(fill: fill, {
  place(left + top, rect(width: 0.55cm, height: 100%, fill: accent))
  if index != none {
    place(top + right, dx: -1.4cm, dy: 1.4cm, text(font: mono, size: 14pt, fill: ink-soft, index))
  }
  block(width: 100%, height: 100%, inset: (left: 2.6cm, right: 1.7cm, y: 1.7cm), body)
})

// ── ruled kicker label used by the examples ────────────────────────────────
#let kicker(t) = grid(
  columns: (0.8cm, auto),
  column-gutter: 0.35cm,
  align: horizon,
  line(length: 0.8cm, stroke: 2pt + accent),
  text(font: mono, size: 13pt, weight: "medium", fill: ink-soft, tracking: 1.5pt, upper(t)),
)
