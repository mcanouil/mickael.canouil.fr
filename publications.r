#!/usr/bin/env Rscript

if (!nzchar(Sys.getenv("QUARTO_PROJECT_RENDER_ALL"))) {
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
        first <- "  first: '*As first or co-first*'"
      } else {
        first <- sprintf(
          "  first: '%s'",
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
        first
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
    "  sort-ui: [date, title, journal-title, position, first]",
    "  filter-ui: [date, title, journal-title]",
    "  fields: [date, title, journal-title, first, position]",
    "  field-display-names:",
    "    date: Issued",
    "    journal-title: Journal",
    "    position: Rank",
    "    first: 'First'",
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
              function(x) any(grepl("As first or co-first", x))
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
