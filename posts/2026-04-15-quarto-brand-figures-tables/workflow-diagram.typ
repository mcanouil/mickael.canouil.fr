#import "@preview/cetz:0.4.2"

#let brand-workflow(
  parser-pkg,
  fonts-pkg,
  figures-pkg,
  tables-pkg,
) = {
  cetz.canvas({
    import cetz.draw: *

    let blue = rgb("#3078b4")
    let teal = rgb("#2d8c8f")
    let violet = rgb("#6a5acd")
    let rose = rgb("#c4586a")

    let quarto-fill = blue.lighten(82%)
    let quarto-stroke = blue.lighten(30%)
    let shared-fill = teal.lighten(82%)
    let shared-stroke = teal.lighten(30%)
    let helper-fill = violet.lighten(82%)
    let helper-stroke = violet.lighten(30%)
    let output-fill = rose.lighten(82%)
    let output-stroke = rose.lighten(30%)

    let r = 0.15
    let h-small = 0.45
    let h-pkg = 0.7

    let draw-node(pos, label, name: none, w: 1.6, h: h-small, fill: luma(240), stroke: luma(120), pkg: none) = {
      rect(
        (pos.at(0) - w, pos.at(1) - h),
        (pos.at(0) + w, pos.at(1) + h),
        radius: r, fill: fill, stroke: stroke, name: name,
      )
      if pkg == none {
        content(pos, text(size: 9pt, raw(label)))
      } else {
        content(
          (pos.at(0), pos.at(1) + 0.15),
          text(size: 9pt, raw(label)),
        )
        content(
          (pos.at(0), pos.at(1) - 0.35),
          text(size: 7.5pt, fill: luma(100), style: "italic", pkg),
        )
      }
    }

    // Row 0: quarto render
    draw-node((0, 0), "quarto render", name: "render", fill: quarto-fill, stroke: quarto-stroke)

    // Row 1: QUARTO_EXECUTE_INFO
    draw-node((0, -1.6), "QUARTO_EXECUTE_INFO", name: "env", w: 2.2, fill: quarto-fill, stroke: quarto-stroke)

    // Row 2: get_brand_info()
    draw-node((0, -3.4), "get_brand_info()", name: "get-brand", w: 1.8, h: if parser-pkg == none { h-small } else { h-pkg }, fill: shared-fill, stroke: shared-stroke, pkg: parser-pkg)

    // Row 3: three helpers
    draw-node((-4, -5.6), "configure_brand_fonts()", name: "fonts", w: 2.2, h: if fonts-pkg == none { h-small } else { h-pkg }, fill: helper-fill, stroke: helper-stroke, pkg: fonts-pkg)
    draw-node((0, -5.6), "theme_brand()", name: "theme", w: 1.6, h: if figures-pkg == none { h-small } else { h-pkg }, fill: helper-fill, stroke: helper-stroke, pkg: figures-pkg)
    draw-node((4, -5.6), "gt_brand()", name: "gt", w: 1.4, h: if tables-pkg == none { h-small } else { h-pkg }, fill: helper-fill, stroke: helper-stroke, pkg: tables-pkg)

    // Row 4: outputs
    draw-node((0, -7.6), "Light / Dark Figures", name: "figures", w: 1.8, fill: output-fill, stroke: output-stroke)
    draw-node((4, -7.6), "Light / Dark Tables", name: "tables", w: 1.8, fill: output-fill, stroke: output-stroke)

    // Arrows
    let arrow-style = (mark: (end: ">", fill: luma(100)), stroke: luma(100) + 0.8pt)

    line("render.south", "env.north", ..arrow-style)
    line("env.south", "get-brand.north", ..arrow-style)

    line("get-brand.south", "fonts.north", ..arrow-style)
    line("get-brand.south", "theme.north", ..arrow-style)
    line("get-brand.south", "gt.north", ..arrow-style)

    line("theme.south", "figures.north", ..arrow-style)
    line("gt.south", "tables.north", ..arrow-style)
  })
}
