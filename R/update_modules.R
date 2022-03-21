gert::git_clone(
  url = "https://github.com/wowchemy/wowchemy-hugo-themes",
  path = "themes/github.com/wowchemy/wowchemy-hugo-themes"
)
files <- list.files(
  path = "themes/github.com/wowchemy/wowchemy-hugo-themes",
  all.files = TRUE,
  full.names = TRUE,
  include.dirs = TRUE,
  no.. = TRUE
)
unlink(
  x = files[!grepl("^wowchemy", basename(files))],
  recursive = TRUE
)
