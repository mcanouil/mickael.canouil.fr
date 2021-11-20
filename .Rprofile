options(
  blogdown.hugo.version = "0.89.2",
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
      theme = "wowchemy/starter-academic",
      hostname = "github.com",
      theme_example = FALSE,
      update_config = TRUE,
      force = TRUE,
      update_hugo = TRUE
    )
  }

  rebuild <- function(...) blogdown::build_site(..., build_rmd = TRUE)

  # python3 -m pip install academic==0.5.1
  # academic import --bibtex content/publications/publications.bib --overwrite
  # academic import --bibtex content/publications/new.bib --overwrite
}
