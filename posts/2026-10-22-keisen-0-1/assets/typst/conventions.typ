// A table written the French way, and an unbounded value.
//
// The separators are set once on the theme rather than on each directive: every
// numeric column below, whichever formatter it goes through, reads
// number-group-separator and number-decimal-separator. Look for a comma in the
// price, the ratio and the mantissa alike, a non-breaking space grouping the
// thousands, and the infinity sitting in the column without disturbing the
// decimal alignment of the numbers above it.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#display-table(
  (
    poste: ("Matériel", "Licences", "Transport", "Divers"),
    montant: (12500.5, 3400.75, 289.9, 42.0),
    ratio: (1.5, 2.25, float.inf, 0.75),
    charge: (0.0000000016, 250000, 9990, 1.6),
  ),
  table-header(title: [Dépenses], subtitle: [Exercice 2026]),
  table-stub(rowname: "poste", label: [Poste]),
  columns-label(montant: [Montant], ratio: [Ratio], charge: [Charge]),
  format-currency("montant", currency: "EUR", position: end),
  format-number("ratio", decimals: 2, infinity: [∞]),
  format-scientific("charge", decimals: 2),
  table-options(
    number-group-separator: sym.space.nobreak,
    number-decimal-separator: ",",
  ),
  theme: theme-booktabs(),
)
