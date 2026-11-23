// 7. Title block: kicker, title, short rule, subtitle, date.
#let title-block(title: none, kicker: none, subtitle: none, date: none) = {
  if kicker != none {
    text(size: 0.75em, weight: "bold", tracking: 0.14em, fill: accent, upper(kicker))
    v(0.4em)
  }
  text(font: font-heading, size: 2em, weight: "bold", title)
  v(0.4em)
  pdf.artifact(line(length: 3em, stroke: 2.5pt + accent))
  if subtitle != none { text(size: 1.15em, fill: muted, subtitle); v(0.2em) }
  if date != none { text(size: 0.85em, fill: muted, date) }
  v(1.5em)
}
