// A nanoplot at the size a nanoplot is meant to be. Every coordinate is a
// fraction of the box, so an em size needs no absolute resolution and no
// minimum canvas: these run inline, at the height of the text around them.

#import "@preview/keisen:0.1.0": nanoplot-bar, nanoplot-line, nanoplot-points

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let series = (3.0, 3.4, 3.1, 4.2, 4.0, 4.9)

Revenue rose through the year #nanoplot-line(series, width: 4em), reading
#nanoplot-points(series, width: 4em) by quarter and
#nanoplot-bar(series, width: 4em) by volume, all at #raw("0.8em").

#set text(size: 16pt)
At a larger text size the plots follow it: #nanoplot-line(series, width: 4em).
