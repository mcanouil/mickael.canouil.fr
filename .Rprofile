source("renv/activate.R")

if (nzchar(system.file(package = "cli"))) {
  cli::cli_alert_info(R.version.string)
  cli::cli_alert_warning(paste0("Config '", cli::col_green("~/.Rprofile"), "' was loaded!"))
} else {
  message(R.version.string)
  message("Config '~/.Rprofile' was loaded!")
}

options(
  width = 150,
  menu.graphics = FALSE,
  renv.config.pak.enabled = TRUE,
  renv.config.cache.enabled = FALSE
)

Sys.setenv(CHROMOTE_CHROME = "/Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser")
