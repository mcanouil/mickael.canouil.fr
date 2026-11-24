// Book cover: decorate page 1 only, because orange-book draws the cover itself. Needs 1-tokens.typ for `accent`.
#let band = gradient.linear(accent, accent.darken(55%), angle: 135deg)
#set page(background: context if here().page() == 1 {
  pdf.artifact({
    place(bottom, rect(width: 100%, height: 35%, fill: band, stroke: none))
    place(top, dy: 12mm, rect(width: 100%, height: 10mm, fill: band, stroke: none))
    place(top, dy: 26mm, rect(width: 100%, height: 2mm, fill: band, stroke: none))
  })
})
