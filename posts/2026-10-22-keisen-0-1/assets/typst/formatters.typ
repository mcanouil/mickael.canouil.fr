// Currency, scientific notation, and byte sizes, each filling a slot the
// alignment stage reserves. The columns are the point: prices line up under
// their symbols, exponents under one another, and units under units, none of
// which happens unless every slot is padded to the column's widest.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#display-table(
  (
    component: ("Sensor", "Controller", "Housing", "Cabling"),
    price: (1250.5, 89.99, 12500, 7.5),
    charge: (0.0000000016, 1.6e-19, 250000, 9990),
    firmware: (512, 2048, 1073741824, 1536000),
  ),
  table-header(title: [Bill of materials], subtitle: [Unit costs and payload sizes]),
  table-stub(rowname: "component", label: [Component]),
  columns-label(price: [Price], charge: [Charge], firmware: [Firmware]),
  format-currency("price", currency: "EUR"),
  format-scientific("charge", decimals: 2),
  format-bytes("firmware"),
  table-source-note([Source: supplier quotations.]),
  theme: theme-booktabs(),
)

#v(1em)

The same figures with the symbol trailing, the exponent written as an e, and
sizes counted in thousands rather than in 1024s.

#display-table(
  (
    component: ("Sensor", "Controller", "Housing", "Cabling"),
    price: (1250.5, 89.99, 12500, 7.5),
    charge: (0.0000000016, 1.6e-19, 250000, 9990),
    firmware: (512, 2048, 1073741824, 1536000),
  ),
  table-stub(rowname: "component", label: [Component]),
  columns-label(price: [Price], charge: [Charge], firmware: [Firmware]),
  format-currency("price", currency: "JPY", position: end),
  format-scientific("charge", exponent: "e"),
  format-bytes("firmware", base: 1000),
  theme: theme-booktabs(),
)
