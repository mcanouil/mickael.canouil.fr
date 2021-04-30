---
# Documentation: https://wowchemy.com/docs/managing-content/

title: "{{ replace .Name "-" " " | title }}"
summary:
abstract:

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
date: {{ .Date }}
date_end: ""
all_day: false

# Schedule page publish date (NOT event date).
publishDate: {{ .Date }}


event: ""
event_url: ""
location: Online (Lille, France)
address:
  street: ""
  city: Lille
  postcode: '59000'
  country: France

# Is this a featured event? (true/false)
featured: false

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder. 
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: ""
  focal_point: Right
  preview_only: false
  
tags:
  - R

# Custom links (optional).
#   Uncomment and edit lines below to show custom links.
links:  
- icon: file-alt
  icon_pack: far
  name: Slides
  url: https://m.canouil.fr/slides/
- icon: film
  icon_pack: fas
  name: Video
  url: https://youtu.be/
- icon: github
  icon_pack: fab
  name: Code
  url: https://github.com/mcanouil/

# Optional filename of your slides within your event's folder or a URL.
# url_slides:
# url_code:
# url_pdf:
# url_video:

# Markdown Slides (optional).
#   Associate this event with Markdown slides.
#   Simply enter your slide deck's filename without extension.
#   E.g. `slides = "example-slides"` references `content/slides/example-slides.md`.
#   Otherwise, set `slides = ""`.
# slides: ""

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: []
---

```{r setup, include = FALSE}
url_slides <- "https://m.canouil.fr/slides/"
url_video <- "https://www.youtube.com/embed/"
```

```{r, include = FALSE, eval = FALSE}
library(magick)
library(here)
library(chromote)
library(glue)

thumb <- "featured.png"
index_html <- url_slides

if (!file.exists(thumb)) {
  web_browser <- suppressMessages(try(chromote::ChromoteSession$new(), silent = TRUE))
  if (inherits(web_browser, "try-error") && Sys.info()[["sysname"]] == "Windows") {
    edge_path <- "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
    if (file.exists(edge_path)) {
      Sys.setenv(CHROMOTE_CHROME = edge_path)
      web_browser <- chromote::ChromoteSession$new()
    } else {
      stop('Please set Sys.setenv(CHROMOTE_CHROME = "Path/To/Chrome")')
    }
  }
  web_browser$Page$navigate(index_html, wait_ = FALSE)
  page_browser <- web_browser$Page$loadEventFired()
  web_browser$screenshot(
    filename = thumb,
    selector = "div.remark-slide-scaler",
    scale = 2
  )
  web_browser$close()
  
  resize <- function(path_in, path_out) {
    image <- image_read(path_in)
    image <- image_resize(image, "1920x")
    image_write(image, path_out)
  }
  resize(thumb, thumb)
}
```

```{r, eval = !is.null(url_video), results = "asis", echo = FALSE, include = TRUE}
cat(
'<div class="embed-responsive embed-responsive-16by9">
  <iframe class="embed-responsive-item" src="', url_video, '" allowfullscreen></iframe>
</div>',
sep = ""
)
```

```{r, eval = !is.null(url_slides), results = "asis", echo = FALSE, include = TRUE}
cat(
'<div class="embed-responsive embed-responsive-16by9 xaringan">
  <iframe class="embed-responsive-item" src="', url_slides, '" allowfullscreen></iframe>
</div>',
sep = ""
)
```
