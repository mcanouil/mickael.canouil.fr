// Source for featured.png, the social card of the post.
// The cover and a body page of the demo report, next to the title.
// The pages are pages 1 and 2 of `typst/_steps/step10.pdf`.
// Run `typst/render-steps.sh` first, then from the post directory:
//   quarto typst compile featured.typ featured.png --ppi 300

#let ink = rgb("#111827")
#let gold = rgb("#b5830a")
#let paper = rgb("#fafafa")
#let muted = rgb("#4b5563")

#set page(width: 8in, height: 4.2in, margin: 0pt, fill: paper)
#set text(font: ("Source Sans 3", "Inter"), fill: ink)

#let sheet(page-number, dx, dy, angle) = place(
  top + left,
  dx: dx,
  dy: dy,
  rotate(angle, origin: top + left, box(
    fill: white,
    stroke: 0.6pt + rgb("#d1d5db"),
    image("typst/_steps/step10.pdf", page: page-number, width: 2.2in, alt: ""),
  )),
)

#place(top + left, dx: 0.5in, dy: 1.0in, block(width: 3.3in)[
  #text(size: 9pt, weight: "bold", tracking: 0.14em, fill: gold)[QUARTO AND TYPST]
  #v(0.6em)
  #text(font: ("Source Serif 4", "Charter"), size: 27pt, weight: "bold")[Professional and accessible PDFs]
  #v(0.8em)
  #text(size: 11pt, fill: muted)[Ten small Typst partials. One file per trick.]
])

#sheet(1, 4.2in, 0.55in, -4deg)
#sheet(2, 5.5in, 0.85in, 3deg)
