// Standalone carousel: every slide in one document, used to build carousel.gif.
// Reuses the shared setup (page, palette, fonts, slide, kicker) from _preamble.typ.

#import "_preamble.typ": *

#set document(title: "Build LinkedIn Carousels with Typst", author: "Mickaël Canouil")
#set text(lang: "en")
#set page(width: 21cm, height: 21cm, margin: 0cm)
#set text(font: body, fill: ink, size: 19pt)

// ── cover ──────────────────────────────────────────────────────────────────
#slide(index: "1 / 3", {
  kicker("Typst · Carousel")
  v(1fr)
  block(width: 16cm, {
    text(font: display, size: 54pt, weight: "bold", fill: ink, "Build decks")
    linebreak()
    text(font: display, size: 54pt, weight: "bold", fill: accent, "from text")
    v(0.4cm)
    text(size: 20pt, fill: ink-soft, "One layout, used on every card.")
  })
  v(1fr)
})

// ── content ────────────────────────────────────────────────────────────────
#slide(index: "2 / 3", {
  kicker("Why Typst")
  v(0.5cm)
  block(
    width: 16cm,
    text(
      font: display, size: 32pt, weight: "bold", fill: ink,
      "Three reasons it fits carousels.",
    ),
  )
  v(0.7cm)

  let row(n, t) = grid(
    columns: (1.3cm, 1fr),
    align: (left + horizon, left + horizon),
    text(font: mono, size: 22pt, weight: "bold", fill: accent, str(n)),
    block(width: 15cm, text(size: 18pt, fill: ink, t)),
  )

  stack(
    dir: ttb,
    spacing: 0.7cm,
    row(1, "Plain text in, PDF out. Diff it, version it, regenerate it."),
    row(2, "One layout sets the look of every page at once."),
    row(3, "No design tool, no manual export, no pixel pushing."),
  )
})

// ── closing ────────────────────────────────────────────────────────────────
#slide(index: "3 / 3", fill: ink, {
  v(1fr)
  kicker("Ship it")
  v(0.5cm)
  text(
    font: display, size: 46pt, weight: "bold", fill: paper,
    "Compile and post.",
  )
  v(0.6cm)
  text(
    font: mono, size: 17pt, fill: rgb("#8fa49d"),
    "typst compile carousel.typ carousel.pdf",
  )
  v(1fr)
})
