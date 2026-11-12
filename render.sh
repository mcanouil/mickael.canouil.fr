#!/usr/bin/env bash

set -euo pipefail

export CHROMOTE_CHROME="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
export PUPPETEER_EXECUTABLE_PATH="${CHROMOTE_CHROME}"

render_pinned_post() {
	# shellcheck source=/dev/null
	(cd "$1" && rig --user proj sync && . .rvenv/bin/activate && quarto render .)
}

# The icons, the wordmarks, and the social card come from `assets/brand/apply.sh`.
# This script does not rebuild them: it only stops when they are out of date.
assets/brand/apply.sh --check

rig --user proj sync
# shellcheck source=/dev/null
. .rvenv/bin/activate

render_pinned_post posts/2020-05-06-ggpacman

render_pinned_post posts/2021-05-06-floating-toc-in-blogdown

render_pinned_post posts/2023-03-05-quarto-auto-table-crossref

render_pinned_post posts/2023-03-12-quarto-mathjax-packages

quarto render posts/2023-05-07-quarto-docker

render_pinned_post posts/2023-05-30-quarto-light-dark

quarto render posts/2024-12-30-quarto-github-pages
quarto render posts/2025-04-21-quarto-revealjs-tabset-pdf
(cd posts/2025-04-21-quarto-revealjs-tabset-pdf/assets && bash featured.sh)
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

# 2026-05-20-gribouille-grammar-of-graphics-for-typst
# Post executes a Python chunk via Jupyter and renders {typst} blocks that
# import @preview/gribouille:0.1.0 (published on Typst Universe, fetched by
# Typst automatically). Prerequisite: a Python environment with `jupyter`,
# `polars`, and `ipython`, exposed to Quarto as a kernel named `gribouille-post`.
uv venv --python 3.13 .venv
# shellcheck source=/dev/null
. .venv/bin/activate
uv pip install jupyter polars ipython
python -m ipykernel install --user --name gribouille-post --display-name "Python (gribouille-post)"
quarto render posts/2026-05-20-gribouille-grammar-of-graphics-for-typst
deactivate

quarto render posts/2026-05-28-typst-linkedin-carousels
quarto render posts/2026-06-03-gribouille-0-2
rig --user run posts/2026-06-10-why-quarto-stuck/assets/scripts/quarto-cli-activity.R
quarto render posts/2026-06-10-why-quarto-stuck
quarto render posts/2026-06-15-gribouille-0-3
quarto render posts/2026-06-22-gribouille-0-4
quarto render posts/2026-07-01-r-package-shiny-quarto
quarto render posts/2026-07-06-shiny-great-docs
quarto render posts/2026-07-13-gribouille-0-5

# 2026-07-24-quarto-stop-duplicating
# The post shows one demo source rendered to HTML, Typst, and reveal.js by the
# `offset-headings`, `prism`, and `cascade` filters. Its outputs are committed
# under `assets/output/`, so they are only rebuilt when the demo changes.
(cd posts/2026-07-24-quarto-stop-duplicating/assets/_demo && quarto render)
quarto render posts/2026-07-24-quarto-stop-duplicating

quarto render posts/2026-07-28-gribouille-0-6
quarto render posts/2026-08-17-quarto-clinical-report

# `assets/_benchmark/run.py` is run by hand, because it reads a local Gribouille build.
bash posts/2026-08-25-gribouille-0-7/assets/_polar/render.sh
quarto render posts/2026-08-25-gribouille-0-7

# `assets/capture/capture.sh` is run by hand, because it drives VS Code over AppleScript.
quarto render posts/2026-09-07-quarto-wizard-3-3
quarto render posts/2026-10-05-quarto-atelier-project-type
quarto render posts/2026-10-22-keisen-0-1
quarto render posts/2026-11-02-nacho-3-0

quarto render
