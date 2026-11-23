// 8. Recurring decoration: stripes at the top, a gradient band behind the footer.
// Typst already treats page backgrounds as artifacts; the wrapper states the intent.
#let band-gradient = gradient.linear(accent, accent.darken(55%), angle: 135deg)
#footer-ink.update(white)

#set page(background: pdf.artifact({
  place(top, dy: 8mm, rect(width: 100%, height: 4mm, fill: band-gradient, stroke: none))
  place(top, dy: 14mm, rect(width: 100%, height: 1mm, fill: band-gradient, stroke: none))
  place(bottom, rect(width: 100%, height: 1.25in, fill: band-gradient, stroke: none))
}))
