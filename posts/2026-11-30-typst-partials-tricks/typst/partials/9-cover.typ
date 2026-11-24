// 9. Cover page: the title block gets a page of its own.
#let cover-art = state("cover-art", none)  // <1>

#let title-block = {
  let block-on-page = title-block
  (..args) => page(
    header: none,
    footer: none,
    background: context cover-art.get(),
    align(horizon, block-on-page(..args)),
  )
}
