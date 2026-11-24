// 2. Header and footer: three slots, page number as "n / total".
#let footer-ink = state("footer-ink", muted)  // <1>

#let slots(start, middle, end) = grid(
  columns: (1fr, auto, 1fr),
  align: (left, center, right),
  start, middle, end,
)

#set page(
  header: context if counter(page).get().first() > 1 {
    set text(size: 0.85em, fill: muted)
    slots([#document.title], [], [Finance])  // <2>
  },
  footer: context {
    set text(size: 0.85em, fill: footer-ink.get())
    slots([], [], [#counter(page).display("1 / 1", both: true)])
  },
)
