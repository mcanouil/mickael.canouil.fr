#!/usr/bin/env bash

set -euo pipefail

Rscript -e "renv::activate(profile = '2020-05-06-ggpacman')"
Rscript -e "renv::restore()"
quarto render posts/2020-05-06-ggpacman

Rscript -e "renv::activate(profile = '2021-05-06-floating-toc-in-blogdown')"
Rscript -e "renv::restore()"
quarto render posts/2021-05-06-floating-toc-in-blogdown

Rscript -e "renv::activate(profile = '2023-03-05-quarto-auto-table-crossref')"
Rscript -e "renv::restore()"
quarto render posts/2023-03-05-quarto-auto-table-crossref

Rscript -e "renv::activate(profile = '2023-03-12-quarto-mathjax-packages')"
Rscript -e "renv::restore()"
quarto render posts/2023-03-12-quarto-mathjax-packages

Rscript -e "renv::activate(profile = 'default')"
Rscript -e "renv::restore()"
quarto render posts/2023-05-07-quarto-docker

Rscript -e "renv::activate(profile = '2023-05-30-quarto-light-dark')"
Rscript -e "renv::restore()"
quarto render posts/2023-05-30-quarto-light-dark

Rscript -e "renv::activate(profile = 'default')"
Rscript -e "renv::restore()"
quarto render posts/2024-12-30-quarto-github-pages
quarto render posts/2025-04-21-quarto-revealjs-tabset-pdf
quarto render posts/2025-05-19-quarto-codespaces
quarto render posts/2025-10-20-quarto-wizard-1-0-0
quarto render posts/2025-11-06-quarto-extensions-lua
quarto render posts/2025-11-20-quarto-editor-settings
quarto render posts/2025-12-12-quarto-extensions-updater
quarto render posts/2026-01-12-quarto-wizard-2-0-0
quarto render posts/2026-01-19-typst-document-dispatcher
quarto render posts/2026-02-27-typst-template-tutorial-part1
quarto render posts/2026-03-05-typst-template-tutorial-part2

quarto render

bash posts/2025-04-21-quarto-revealjs-tabset-pdf/assets/featured.sh
