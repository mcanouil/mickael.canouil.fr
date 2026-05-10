#import "@preview/cetz:0.5.0"

#let bridge-diagram() = {
  cetz.canvas({
    import cetz.draw: *

    let blue = rgb("#3078b4")
    let teal = rgb("#2d8c8f")
    let rose = rgb("#c4586a")
    let success = rgb("#2f8f5e")

    let lua-band-fill = blue.lighten(88%)
    let lua-band-stroke = blue.lighten(40%)
    let typst-band-fill = teal.lighten(88%)
    let typst-band-stroke = teal.lighten(40%)

    let node-fill = white
    let node-stroke = luma(140) + 0.7pt
    let code-fill = blue.lighten(75%)
    let code-stroke = blue.lighten(20%) + 0.7pt
    let pipeline-fill = rose.lighten(78%)
    let pipeline-stroke = rose.lighten(20%) + 0.7pt
    let renderer-fill = teal.lighten(75%)
    let renderer-stroke = teal.lighten(20%) + 0.7pt

    let arrow-style = (mark: (end: ">", fill: luma(110)), stroke: luma(110) + 0.9pt)
    let strong-arrow = (mark: (end: ">", fill: luma(70)), stroke: luma(70) + 1.1pt)

    let draw-node(
      pos,
      label,
      name: none,
      w: 1.2,
      h: 0.45,
      fill: node-fill,
      stroke: node-stroke,
      mono: false,
      mono-size: 8pt,
    ) = {
      rect(
        (pos.at(0) - w, pos.at(1) - h),
        (pos.at(0) + w, pos.at(1) + h),
        radius: 0.12,
        fill: fill,
        stroke: stroke,
        name: name,
      )
      if mono {
        content(pos, text(size: mono-size, raw(label)))
      } else {
        content(pos, text(size: 9.5pt, label))
      }
    }

    let draw-pill(pos, label, name: none) = {
      let w = 1.5
      let h = 0.42
      rect(
        (pos.at(0) - w, pos.at(1) - h),
        (pos.at(0) + w, pos.at(1) + h),
        radius: h,
        fill: success,
        stroke: success.darken(20%) + 0.7pt,
        name: name,
      )
      content(
        pos,
        text(size: 9.5pt, fill: white, weight: "semibold", "✓ " + label),
      )
    }

    let band-left = -0.4
    let band-right = 15.6
    let lua-top = 4.4
    let lua-bottom = 0.4
    let typst-top = -1.2
    let typst-bottom = -4.6

    rect(
      (band-left, lua-bottom),
      (band-right, lua-top),
      radius: 0.2,
      fill: lua-band-fill,
      stroke: lua-band-stroke + 0.6pt,
    )
    content(
      (band-left + 0.25, lua-top - 0.35),
      anchor: "west",
      text(size: 9pt, fill: blue.darken(20%), weight: "bold", "Lua layer (Pandoc + filter)"),
    )

    rect(
      (band-left, typst-bottom),
      (band-right, typst-top),
      radius: 0.2,
      fill: typst-band-fill,
      stroke: typst-band-stroke + 0.6pt,
    )
    content(
      (band-left + 0.25, typst-top - 0.35),
      anchor: "west",
      text(size: 9pt, fill: teal.darken(20%), weight: "bold", "Typst layer (renderer)"),
    )

    let lua-y = 2.4

    draw-node(
      (2.4, lua-y),
      "[Completed]{.badge colour=\"success\"}",
      name: "md",
      w: 2.2,
      h: 0.55,
      fill: code-fill,
      stroke: code-stroke,
      mono: true,
      mono-size: 7.5pt,
    )

    draw-node(
      (6.6, lua-y),
      "Pandoc AST",
      name: "ast",
      w: 1.1,
      h: 0.55,
      fill: pipeline-fill,
      stroke: pipeline-stroke,
    )

    draw-node(
      (9.4, lua-y),
      "Lua filter",
      name: "lua",
      w: 1.1,
      h: 0.55,
      fill: pipeline-fill,
      stroke: pipeline-stroke,
    )

    draw-node(
      (13.0, lua-y),
      "#simple-badge(...)[Completed]",
      name: "code",
      w: 2.0,
      h: 0.55,
      fill: code-fill,
      stroke: code-stroke,
      mono: true,
      mono-size: 7.5pt,
    )

    line("md.east", "ast.west", ..arrow-style)
    line("ast.east", "lua.west", ..arrow-style)
    line("lua.east", "code.west", ..arrow-style)

    let typst-y = -2.9

    draw-node(
      (10.2, typst-y),
      "Typst function",
      name: "fn",
      w: 1.4,
      h: 0.55,
      fill: renderer-fill,
      stroke: renderer-stroke,
    )

    draw-pill((13.6, typst-y), "Completed", name: "pill")

    line("fn.east", "pill.west", ..arrow-style)

    line(
      "code.south",
      "fn.north",
      ..strong-arrow,
    )
    content(
      (12.0, (lua-bottom + typst-top) / 2),
      anchor: "west",
      text(size: 7.5pt, fill: luma(80), style: "italic", "hand-off"),
    )
  })
}
