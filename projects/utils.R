# library(magick)
# library(here)
# library(chromote)
# library(glue)

make_feature <- function(url, repo, thumb) {
  if (!file.exists(thumb)) {
    web_browser <- suppressMessages(try(chromote::ChromoteSession$new(), silent = TRUE))
    if (file.exists(chromote::find_chrome())) {
      Sys.setenv(CHROMOTE_CHROME = "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser")
    }
    web_browser$Page$navigate(url, wait_ = FALSE)
    page_browser <- web_browser$Page$loadEventFired()
    web_browser$screenshot(
      filename = thumb,
      selector = "div.remark-slide-scaler",
      scale = 2
    )
    web_browser$close()

    resize <- function(path_in, path_out) {
      image <- magick::image_read(path_in)
      image <- magick::image_resize(image, "1920x")
      magick::image_write(image, path_out)
    }
    resize(thumb, thumb)
  }
  cat(
    c(
      '<center>',
      '<div class="xaringanslides" style="min-width:300px;margin:1em auto;">',
      '  <iframe src="', url, '" width="560" height="315" style="border:2px solid currentColor;" loading="lazy" allowfullscreen></iframe>',
      '  <script>fitvids(".xaringanslides", {players: "iframe"});</script>',
      '</div>',
      '</center>',
      '',
      '*Source: <', repo, '>*'
    ),
    sep = ""
  )

}
