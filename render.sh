#!/usr/bin/env bash

set -euo pipefail

Rscript -e "renv::activate(profile = '2020-05-06-ggpacman'); renv::restore()"
quarto render posts/2020-05-06-ggpacman

Rscript -e "renv::activate(profile = '2021-05-06-floating-toc-in-blogdown'); renv::restore()"
quarto render posts/2021-05-06-floating-toc-in-blogdown

Rscript -e "renv::activate(profile = '2023-03-05-quarto-auto-table-crossref'); renv::restore()"
quarto render posts/2023-03-05-quarto-auto-table-crossref

Rscript -e "renv::activate(profile = '2023-03-12-quarto-mathjax-packages'); renv::restore()"
quarto render posts/2023-03-12-quarto-mathjax-packages

Rscript -e "renv::activate(profile = 'default'); renv::restore()"
quarto render posts/2023-05-07-quarto-docker

Rscript -e "renv::activate(profile = '2023-05-30-quarto-light-dark'); renv::restore()"
quarto render posts/2023-05-30-quarto-light-dark

Rscript -e "renv::activate(profile = 'default'); renv::restore()"
quarto render posts/2024-12-30-quarto-github-pages
quarto render posts/2025-04-21-quarto-revealjs-tabset-pdf
bash posts/2025-04-21-quarto-revealjs-tabset-pdf/assets/featured.sh
quarto render posts/2025-05-19-quarto-codespaces
quarto render posts/2025-10-20-quarto-wizard-1-0-0
quarto render posts/2025-11-06-quarto-extensions-lua
quarto render posts/2025-11-20-quarto-editor-settings
quarto render posts/2025-12-12-quarto-extensions-updater
quarto render posts/2026-01-12-quarto-wizard-2-0-0
quarto render posts/2026-01-19-typst-document-dispatcher
quarto render posts/2026-02-27-typst-template-tutorial-part1
quarto render posts/2026-03-05-typst-template-tutorial-part2
quarto render posts/2026-04-15-quarto-brand-figures-tables
quarto render posts/2026-04-21-quarto-revealjs-extensions
quarto render posts/2026-05-28-typst-linkedin-carousels
quarto render posts/2026-06-03-gribouille-0-2
Rscript posts/2026-06-10-why-quarto-stuck/assets/scripts/quarto-cli-activity.R
quarto render posts/2026-06-10-why-quarto-stuck

# 2026-05-20-gribouille-grammar-of-graphics-for-typst
# Post executes a Python chunk via Jupyter and renders {typst} blocks that
# import @preview/gribouille:0.1.0 (published on Typst Universe, fetched by
# Typst automatically). Prerequisite: a Python environment with `jupyter`,
# `polars`, and `ipython`, exposed to Quarto as a kernel named `gribouille-post`.
uv venv --python 3.13 .venv
. .venv/bin/activate
uv pip install jupyter polars ipython
python -m ipykernel install --user --name gribouille-post --display-name "Python (gribouille-post)"
quarto render posts/2026-05-20-gribouille-grammar-of-graphics-for-typst
deactivate

quarto render
