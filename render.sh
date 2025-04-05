#!/usr/bin/env bash

set -e

Rscript -e "renv::activate(profile = '2020-05-06-ggpacman')"
quarto render posts/2020-05-06-ggpacman

Rscript -e "renv::activate(profile = '2021-05-06-floating-toc-in-blogdown')"
quarto render posts/2021-05-06-floating-toc-in-blogdown

Rscript -e "renv::activate(profile = '2023-03-05-quarto-auto-table-crossref')"
quarto render posts/2023-03-05-quarto-auto-table-crossref

Rscript -e "renv::activate(profile = '2023-03-12-quarto-mathjax-packages')"
quarto render posts/2023-03-12-quarto-mathjax-packages

Rscript -e "renv::activate(profile = 'default')"
quarto render posts/2023-05-07-quarto-docker

Rscript -e "renv::activate(profile = '2023-05-30-quarto-light-dark')"
quarto render posts/2023-05-30-quarto-light-dark

Rscript -e "renv::activate(profile = 'default')"
quarto render posts/2024-12-30-quarto-github-pages

Rscript -e "renv::activate(profile = 'default')"
quarto render
