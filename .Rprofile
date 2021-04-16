if (interactive()) {
  options(
    blogdown.hugo.version = "0.82.0",
    # to automatically serve the site on RStudio startup, set this option to TRUE
    blogdown.serve_site.startup = FALSE,
    # to disable knitting Rmd files on save, set this option to FALSE
    blogdown.knit.on_save = FALSE,
    blogdown.author = "mcanouil",
    blogdown.ext = ".Rmd",
    blogdown.subdir = "post"
  )
  
  library(blogdown)
  library(gert)
  
  update <- function() {
    install_theme(
      theme = "wowchemy/starter-academic",
      hostname = "github.com",
      theme_example = FALSE,
      update_config = FALSE,
      force = TRUE,
      update_hugo = TRUE
    )
  }
  
  snapshot <- function(pkgs = NULL, lockfile = "renv.lock") {
    if (is.null(pkgs)) {
      pkgs <- unique(renv::dependencies()[["Package"]])
    }
    if (!file.exists(lockfile)) {
      renv:::renv_lockfile_write(renv:::renv_lockfile_init_r("."), file = lockfile)
    }
    renv::record(
      records = lapply(
        X = structure(pkgs, names = pkgs), 
        FUN = function(x) as.character(utils::packageVersion(x))
      ),
      lockfile = lockfile
    )
    unlink("renv", recursive = TRUE)
  }
}



