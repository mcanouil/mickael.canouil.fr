// 6. Captions: small, muted, with the label in bold.
#show figure.caption: set text(size: 0.85em, fill: muted)
#show figure.caption: it => {
  strong(it.supplement + [ ] + context it.counter.display(it.numbering))
  [. ]
  it.body
}
