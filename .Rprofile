# source("renv/activate.R")

if (nzchar(system.file(package = "cli"))) {
  cli::cli_alert_info(R.version.string)
  cli::cli_alert_warning(paste0("Config '", cli::col_green("~/.Rprofile"), "' was loaded!"))
} else {
  message(R.version.string)
  message("Config '~/.Rprofile' was loaded!")
}

options(
  languageserver.formatting_style = function(options, ...) {
    transformers <- styler::tidyverse_style(indent_by = options$tabSize, ...)
    transformers$indention$update_indention_ref_fun_dec <- NULL
    transformers$indention$unindent_fun_dec <- NULL
    transformers$line_break$remove_line_breaks_in_fun_dec <- NULL
    transformers
  }
)

Sys.setenv(CHROMOTE_CHROME = "/Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser")

if (interactive()) {
  options(
    width = 200,
    menu.graphics = FALSE
  )
}
