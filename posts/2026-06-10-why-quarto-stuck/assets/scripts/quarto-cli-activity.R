#!/usr/bin/env Rscript
# Generate assets/data/quarto-cli-activity.csv from mcanouil/quarto-cli-activity report data.

suppressPackageStartupMessages({
  library(jsonlite)
  library(dplyr)
  library(readr)
})

report_url <- paste0(
  "https://raw.githubusercontent.com/",
  "mcanouil/quarto-cli-activity/main/data/reports/mcanouil/data.json"
)

out <- here::here(
  "posts/2026-06-10-why-quarto-stuck/assets/data/quarto-cli-activity.csv"
)

monthly <- as_tibble(fromJSON(report_url)[["monthly"]])

# Discussions = Discussion Comments
# Issues      = Issue Comments
# PRs         = PR Comments + PR Reviews
activity <- monthly |>
  filter(
    .data[["metric"]] %in%
      c("Discussion Comments", "Issue Comments", "PR Comments", "PR Reviews")
  ) |>
  mutate(
    kind = recode_values(
      .data[["metric"]],
      "Discussion Comments" ~ "Discussions",
      "Issue Comments" ~ "Issues",
      c("PR Comments", "PR Reviews") ~ "PRs"
    )
  ) |>
  summarise(count = sum(.data[["count"]]), .by = c("month_num", "kind")) |>
  rename(x = "month_num") |>
  arrange(.data[["x"]], .data[["kind"]])

dir.create(dirname(out), showWarnings = FALSE, recursive = TRUE)
write_csv(activity, out)
message("Written: ", out)
