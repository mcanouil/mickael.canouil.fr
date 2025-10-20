#!/usr/bin/env Rscript

if (
  !nzchar(Sys.getenv("QUARTO_PROJECT_RENDER_ALL")) &&
    grepl("publications.qmd", Sys.getenv("QUARTO_PROJECT_INPUT_FILES"))
) {
  quit()
}

create_pub_listing <- function(bib_file, author = "Canouil") {
  bib <- strsplit(paste(readLines(bib_file), collapse = "\n"), "\n@")[[1]]
  articles <- lapply(
    X = paste0("@", bib[bib != ""]),
    FUN = function(ibib) {
      f <- tempfile()
      on.exit(unlink(f))
      writeLines(ibib, f)
      article <- tail(
        head(
          system(
            command = paste(
              "pandoc",
              f,
              "--standalone",
              "--from=bibtex",
              "--to=markdown"
            ),
            intern = TRUE
          ),
          -2
        ),
        -3
      )
      authors <- sub(
        ".*- family: ",
        "",
        grep("- family:", article, value = TRUE)
      )
      if (isTRUE(grepl("first", grep("annote:", article, value = TRUE)))) {
        as_first <- "  first: '*As first or co-first*'"
      } else {
        as_first <- sprintf(
          "  first: '%s'",
          paste(rep("&emsp;", 3), collapse = "")
        )
      }
      if (isTRUE(grepl("last", grep("annote:", article, value = TRUE)))) {
        as_last <- "  last: '*As last or co-last*'"
      } else {
        as_last <- sprintf(
          "  last: '%s'",
          paste(rep("&emsp;", 3), collapse = "")
        )
      }
      position <- sprintf(
        "  position: '%s/%s'",
        grep(author, authors),
        length(authors)
      )
      article <- c(
        article,
        sub(
          "  container-title: (.*)",
          "  journal-title: '*\\1*'",
          grep("  container-title:", article, value = TRUE)
        ),
        sub("  issued: ", "  date: ", grep("  issued:", article, value = TRUE)),
        sub(
          "  doi: ",
          "  path: https://doi.org/",
          grep("doi:", article, value = TRUE)
        ),
        position,
        as_first,
        as_last
      )
      article
    }
  )
  writeLines(text = unlist(articles), con = sub("\\.bib$", ".yml", bib_file))

  yaml_text <- c(
    "---",
    "title: 'Publications (%s)'",
    "title-block-banner: true",
    "image: /assets/images/social-profile.png",
    "date-format: 'MMMM,<br>YYYY'",
    "listing:",
    "  contents:",
    "    - publications.yml",
    "  page-size: 10",
    "  sort: 'issued desc'",
    "  type: table",
    "  categories: false",
    "  sort-ui: [date, title, journal-title, first, last]",
    "  filter-ui: [date, title, journal-title]",
    "  fields: [date, title, journal-title, first, last]",
    "  field-display-names:",
    "    date: Issued",
    "    journal-title: Journal",
    "    first: 'First'",
    "    last: 'Last'",
    "---"
  )

  writeLines(
    text = sprintf(
      yaml_text,
      paste(
        table(
          factor(
            x = sapply(
              articles,
              function(x) {
                any(grepl("As first or co-first|As last or co-last", x))
              }
            ),
            levels = c("TRUE", "FALSE")
          )
        )[c("TRUE", "FALSE")],
        collapse = " + "
      )
    ),
    con = sub("\\.bib$", ".qmd", bib_file)
  )
}

create_pub_listing("publications.bib")
