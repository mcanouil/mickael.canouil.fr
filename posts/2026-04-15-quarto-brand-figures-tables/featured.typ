#import "workflow-diagram.typ": brand-workflow

#set page(
  width: 600pt,
  height: 315pt,
  margin: (top: 1cm, bottom: 0.6cm, left: 1cm, right: 1cm),
  fill: white,
)

#place(
  top + right,
  dx: -0.5cm,
  dy: 0.5cm,
  image("quarto-logo-trademark.svg", width: 5cm),
)

#align(center + horizon, brand-workflow(none, none, none, none))
