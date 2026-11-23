// 1. Tokens: change a value here, change the whole document.
#let ink = rgb("#1f2933")
#let accent = rgb("#0b6e99")
#let muted = rgb("#586270")
#let tint = rgb("#eef3f7")
#let font-body = ("Source Sans 3", "Libertinus Serif")
#let font-heading = ("Inter", "Libertinus Serif")
#let font-code = ("Fira Code", "DejaVu Sans Mono")

#set text(font: font-body, fill: ink)
#show heading: set text(font: font-heading)
#show raw: set text(font: font-code)
#show link: set text(fill: accent)
#show link: underline
