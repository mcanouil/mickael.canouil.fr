// 10. Cover decoration: a gradient band at the bottom, two stripes at the top.
#let cover-gradient = gradient.linear(accent, accent.darken(55%), angle: 135deg)

#cover-art.update(pdf.artifact({  // <1>
  place(bottom, rect(width: 100%, height: 35%, fill: cover-gradient, stroke: none))
  place(top, dy: 12mm, rect(width: 100%, height: 10mm, fill: cover-gradient, stroke: none))
  place(top, dy: 26mm, rect(width: 100%, height: 2mm, fill: cover-gradient, stroke: none))
}))
