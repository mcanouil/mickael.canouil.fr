// Source for featured.png, the social card of the post.
// The cover and a body page of the demo report, next to the title.
// The pages are `assets/_featured-1.png` and `assets/_featured-2.png`:
//   pdftoppm -r 150 -png -f 1 -l 2 typst/_steps/step10.pdf assets/_featured
// Then, from the post directory:
//   typst compile featured.typ featured.png --ppi 300

#let ink = rgb("#111827")
#let gold = rgb("#b5830a")
#let paper = rgb("#fafafa")
#let muted = rgb("#4b5563")

#set page(width: 8in, height: 4.2in, margin: 0pt, fill: paper)
#set text(font: ("Source Sans 3", "Inter"), fill: ink)

#let sheet(path, dx, dy, angle) = place(
  top + left,
  dx: dx,
  dy: dy,
  rotate(angle, origin: top + left, box(
    stroke: 0.6pt + rgb("#d1d5db"),
    image(path, width: 2.2in, alt: ""),
  )),
)

#place(top + left, dx: 0.5in, dy: 1.0in, block(width: 3.3in)[
  #text(size: 9pt, weight: "bold", tracking: 0.14em, fill: gold)[QUARTO AND TYPST]
  #v(0.6em)
  #text(font: ("Source Serif 4", "Charter"), size: 27pt, weight: "bold")[Ten small partials for a better PDF]
  #v(0.8em)
  #text(size: 11pt, fill: muted)[One file per trick. Copy it, change it or delete it.]
])

#sheet("assets/_featured-1.png", 4.2in, 0.55in, -4deg)
#sheet("assets/_featured-2.png", 5.5in, 0.85in, 3deg)
