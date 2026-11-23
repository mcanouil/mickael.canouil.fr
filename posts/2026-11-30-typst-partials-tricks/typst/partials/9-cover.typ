// 9. Cover page: the title block gets a page of its own.
// `cover-art` is a slot for decoration, empty until trick 10 fills it.
#let cover-art = state("cover-art", none)

#let title-block = {
  let block-on-page = title-block
  (..args) => page(
    header: none,
    footer: none,
    background: context cover-art.get(),
    align(horizon, block-on-page(..args)),
  )
}
