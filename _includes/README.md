# Shared home-page sections

Each `.qmd` file here is one section of the home page, included by two compositions:

- `index.qmd`, the home page of <https://mickael.canouil.fr>, which adds the project, blog, and
  publication listings between these sections.
- `_profile.qmd`, the GitHub profile landing page at <https://m.canouil.dev>, built from this repository by
  [`mcanouil/mcanouil.github.io`](https://github.com/mcanouil/mcanouil.github.io), which renders a single
  page and therefore carries no listings.

Two rules keep both compositions valid.

1. **No site-relative links.**
   A link such as `/projects/index.qmd` cannot resolve in the single-page profile project.
   Cross-page links belong to the including file, which knows whether to write them site-relative or
   absolute.
   External links, DOIs, and `mailto:` are fine.

2. **Each file opens and closes its own divs.**
   Fences must not straddle an include boundary; only the `.about-body` wrapper lives in the composition.

Quarto ignores directories beginning with `_`, so nothing here renders as a page.
