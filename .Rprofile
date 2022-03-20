options(
  blogdown.hugo.version = "0.94.2",
  # to automatically serve the site on RStudio startup, set this option to TRUE
  blogdown.serve_site.startup = FALSE,
  # to disable knitting Rmd files on save, set this option to FALSE
  blogdown.knit.on_save = FALSE,
  blogdown.author = "mickael-canouil",
  blogdown.ext = ".Rmd",
  blogdown.subdir = "post",
  blogdown.method = "markdown",
  blogdown.time = TRUE
)

if (interactive()) {
  library(blogdown)

  update <- function() {
    install_theme(
      theme = "wowchemy/starter-hugo-academic",
      hostname = "github.com",
      theme_example = FALSE,
      update_config = TRUE,
      force = TRUE,
      update_hugo = FALSE
    )
  }

  rebuild <- function(build_rmd = "timestamp", ...) blogdown::build_site(..., build_rmd = build_rmd)

  # python3 -m pip install academic
  # academic import --bibtex content/publications/publications.bib --overwrite
  # academic import --bibtex content/publications/new.bib --overwrite
}
