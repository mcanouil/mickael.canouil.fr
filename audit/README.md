# Accessibility audit harness

axe-core (via Puppeteer + Brave) and WCAG contrast checks against the rendered `_site/`.

## Prerequisites

- Quarto-rendered `_site/` at the project root.
- Brave Browser at `/Applications/Brave Browser.app/` (or edit `audit.mjs` to point at any Chromium binary).
- Node.js 22+.

## Install

```bash
cd audit
npm install --no-save puppeteer @axe-core/puppeteer axe-core wcag-contrast http-server
```

## Run

```bash
# Serve _site/ on :8080 in the background.
npx --yes http-server ../_site -p 8080 --silent &
SERVER_PID=$!

# WCAG axe scan on a 7-URL sample (light mode).
node audit.mjs light

# Same sample in dark mode (toggles via window.toggleColorMode(true)).
node audit.mjs dark

# Compute WCAG contrast for the palette pairs the rendered HTML uses.
node contrast.mjs > contrast.tsv

# Aggregate summary.
node summarise.mjs > audit-summary.txt

# Tear down server.
kill "$SERVER_PID"
```

## Pass criteria

- `audit-light.json` and `audit-dark.json`: zero **critical** violations on the seven sample URLs (image-alt, aria-required-children, aria-required-parent).
- Listing pages (`index.html`, `blog.html`, `projects/index.html`, `publications/index.html`, `talks/index.html`) show zero violations.
- Individual posts: the only remaining violations should be third-party (`github-light` syntax theme, typst-render output) or content-driven (per-post `fig-alt` / image alt text).
- `contrast.tsv`: every WCAG AA pair (≥ 4.5:1 normal, ≥ 3:1 large) marked `PASS`.

## Files

- `audit.mjs` — Puppeteer driver + axe-core injection. Outputs `audit-{light,dark}.json`.
- `contrast.mjs` — WCAG ratio for every palette pair we use (light + dark).
- `summarise.mjs` — Human-readable per-URL summary.
- `package.json` — npm metadata (no committed lockfile).
