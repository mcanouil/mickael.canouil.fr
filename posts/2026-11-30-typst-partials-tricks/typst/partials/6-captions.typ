// 6. Captions: small, muted, with the label in bold when the figure is numbered.
#show figure.caption: set text(size: 0.85em, fill: muted)
#show figure.caption: it => {
  if it.numbering != none and it.supplement != none {
    strong(it.supplement + [ ] + context it.counter.display(it.numbering))
    [. ]
  }
  it.body
}
