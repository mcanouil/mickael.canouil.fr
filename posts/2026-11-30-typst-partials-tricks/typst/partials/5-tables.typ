// 5. Tables: filled header, zebra stripes.
#set table(
  fill: (_, y) => if y == 0 { accent } else if calc.odd(y) { tint },
  stroke: none,
  inset: 0.6em,
)
#show table.cell.where(y: 0): set text(fill: white, weight: "bold")
#show table: set text(size: 0.9em)
