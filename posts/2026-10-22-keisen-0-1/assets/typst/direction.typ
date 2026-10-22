// The same table twice, once in left-to-right text and once in right-to-left.
// In the right-to-left table, look for these things:
//
//   - the columns run the other way, stub last;
//   - the title, the labels and the text cells sit against the right edge;
//   - the amounts sit against the left edge, still lined up on their decimal
//     separators, and each still reads 1 256.750 rather than 750.256 1.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let readings = (
  station: ("Alpha", "Beta", "Gamma"),
  region: ("North", "North", "South"),
  amount: (1256.75, 8.5, 340.125),
  share: (0.62, 0.31, 0.07),
)

#let build = display-table.with(
  readings,
  table-header(title: [Readings], subtitle: [Two directions, one table]),
  table-stub(rowname: "station", group: "region", label: [Station]),
  columns-label(amount: [Amount], share: [Share]),
  format-number("amount", decimals: 3),
  format-percent("share", decimals: 1),
  summary-rows(functions: (Total: aggregate-sum), columns: ("amount",)),
  table-source-note([Source: station log.]),
)

Left to right.

#build()

#v(1em)

#set text(dir: rtl)

Right to left.

#build()
