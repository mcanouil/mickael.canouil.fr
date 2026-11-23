// 3. Headings: coloured numbers, never stranded at the bottom of a page.
#show heading: it => block(sticky: true, above: 1.6em, below: 0.8em)[
  #if it.numbering != none {
    text(fill: accent, counter(heading).display(it.numbering))
    h(0.5em)
  }
  #it.body
]
