// One column built from several. The pattern reads the formatted content of its
// sources, which is why the estimate keeps two decimals and the error three:
// each source was formatted by its own directive before the pattern saw it.
//
// The labels are centred with `column-labels-align`. The stubhead and the
// column labels both follow it.

#import "@preview/keisen:0.1.0": *

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#display-table(
  (
    gene: ("BRCA1", "TP53", "PTEN", "APC"),
    estimate: (1.234, -0.567, 0.089, 2.401),
    error: (0.021, 0.043, 0.112, 0.008),
    lower: (1.193, -0.651, -0.130, 2.385),
    upper: (1.275, -0.483, 0.308, 2.417),
    p: (0.0000012, 0.031, 0.42, 0.0000000004),
  ),
  table-header(title: [Association results], subtitle: [Effect per copy of the minor allele]),
  table-stub(rowname: "gene", label: [Gene]),
  format-number("estimate", decimals: 2),
  format-number("error", decimals: 3),
  format-number(("lower", "upper"), decimals: 2),
  format-scientific("p", decimals: 1),
  columns-combine(
    "effect",
    ("estimate", "error"),
    (value, margin) => [#value #h(0.2em) (#margin)],
    label: [Effect (SE)],
  ),
  columns-combine(
    "interval",
    ("lower", "upper"),
    (low, high) => [#low #sym.dash.en #high],
    label: [95% CI],
  ),
  columns-label(p: [_p_]),
  // A combined column holds content, not numbers, so no alignment is inferred
  // for it. This puts it against the end edge.
  columns-align(end, columns: "effect"),
  table-options(column-labels-align: center),
  table-source-note([Source: association study.]),
  theme: theme-booktabs(),
)
