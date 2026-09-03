// The image on the card is real Typst output: this is the cell of the fixture
// the post shows, compiled with the Typst binary that ships inside Quarto.
//
// quarto typst compile _plot.typ plot.svg
// node screenshot.mjs
#import "@preview/gribouille:0.7.0": *

#set page(width: auto, height: auto, margin: 4pt, fill: none)
#set text(size: 13pt)

// The theme carries the colours, because Gribouille draws its labels as
// glyph paths with their own fill and a document-wide text fill never
// reaches them. White ink over the midnight card of the wizard website.

#plot(
  data: penguins,
  mapping: aes(x: "flipper-len", y: "body-mass", colour: "species"),
  layers: (geom-point(),),
  theme: theme-minimal(ink: white),
  width: 10cm,
  height: 7cm,
)
