# mickaelcanouilfr

Local Quarto HTML format extension for `mickael.canouil.fr`.
Editorial-luxury aesthetic derived from the author's Typst CV: gold accent on near-black ink, Georgia serif, dashed gold link underlines, dark navbar/footer, accent rule dividers, warm gradient body background.

## Activation

Set the format in the project's `_quarto.yml`:

```yaml
format:
  mickaelcanouilfr-html:
    grid:
      body-width: 1000px
```

The extension also contributes a `project.website` block (favicon, navbar logo, navigation defaults), so no path references to `_extensions/mickaelcanouilfr/...` need appear in the site config.

## brand.yml support

All extension SCSS variables use `!default`, so a project-level `_brand.yml` overrides them.

```yaml
color:
  palette:
    accent: "#0066cc"
  primary: accent
  foreground: "#111827"
  background: "#fafafa"
typography:
  fonts:
    - family: Georgia
      source: system
  base: Georgia
  link:
    color: accent
```

## Directory layout

```
_extensions/mickaelcanouilfr/
├── _extension.yml
├── LICENSE
├── README.md
├── scss/
│   ├── mickaelcanouilfr.scss     entry, composes layers + partials
│   ├── _defaults.scss            scss:defaults — palette, fonts, tokens
│   ├── _dark.scss                dark-mode defaults overrides
│   ├── _rules.scss               scss:rules — selectors
│   ├── _projects.scss            projects listing
│   ├── _publications.scss        publications listing
│   └── _carousel.scss            featured carousel
├── filters/
│   └── current-year.lua          [current-year] span replacement
└── assets/
    ├── images/                   logo variants (light, dark, gold, ink)
    └── scripts/                  client-side JS hooks
        ├── categories-alphabetical.html
        ├── navbar-tooltips.html
        ├── ordinal-dates.html
        ├── publications-clipboard.html
        ├── title-block-header.html
        └── year-toc.html
```
