# Capturing the images of this post

`capture.sh` writes every screenshot and the animation of this post.
Run it again whenever Quarto Wizard, the typst-render extension, or the theme changes the picture.

```bash
posts/2026-09-03-quarto-wizard-3-3/assets/capture/capture.sh both
```

The argument is `light`, `dark`, or `both`, which is the default.
The images go to `../media`, under the names the post uses, at 1400 pixels wide, as lossless WebP.
Set `OUT` to write them somewhere else.

## What you need

- Quarto Wizard 3.3 or later, the GitHub theme, and the Quarto extension, all installed in `~/.vscode/extensions`.
  The script copies those three into `/tmp/qw-ext`, so no other extension of yours shows up in a shot.
- Quarto, for the Typst binary the preview uses.
- The `typst-render` extension of this website, under `_extensions/mcanouil`.
  The script copies it into the fixture project.
- Gribouille 0.7.0 in the local Typst package cache, or a network connection for the first compile.
- Screen Recording and Accessibility permission for the terminal that runs the script.
  For an integrated terminal, that is Visual Studio Code itself.
  An update of that application invalidates the Accessibility grant, so it has to be given again after one.
  The script says so and stops.
- `magick`, `cwebp` and `img2webp` from Homebrew, and `uv` for the pointer moves.

## How it works

The script writes its own fixture project to `/tmp/qw-demo`:

- `demo.qmd`, holding one Typst cell, one raw block and one plain block.
  The cell asks the extension for `background: auto` and `foreground: auto`, so the image follows the theme of the editor.
- `_quarto.yml`, with the two wrong extension options the diagnostics shot reports, and the two sides of the brand.
- `_brand-light.yml` and `_brand-dark.yml`, which is where those `auto` colours come from.
- `_preamble.typ`, which imports Gribouille.
The fixture is written by the script rather than stored here, so this folder holds no `.qmd` and no `_quarto.yml` that the website would try to render.

It then opens that folder in a throwaway profile at `/tmp/qw-shot`, moves the cursor with `code --goto`, runs commands through the command palette, and moves the pointer with a small Quartz call.
Every event is addressed to the process id of the capture window, and the script stops rather than type into any other window.

## When a shot moves

Three constants near the top of the script hold the geometry of the text: `EDITOR_DX`, `CHAR_W10`, and the two vertical offsets `Y_PREAMBLE` and `Y_RECT`.
They are measured from a capture, because a code lens takes a row of its own and is shorter than a line of text.
Change the font size, the line height, or the fixture, and the two hover shots need those numbers measured again.

The script also addresses the fixture by line and column, in the `capture_profile` and `capture_animation` calls.
Add or remove a line in either heredoc and those numbers move with it.
