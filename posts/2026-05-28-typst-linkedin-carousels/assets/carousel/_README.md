# _carousel.typ

Source for the looping `carousel.gif`: the three example cards from the post collected into one standalone deck.

It imports the shared setup from `../../_preamble.typ`, so it must be compiled with the post directory as the Typst root.
Building the GIF needs [ImageMagick](https://imagemagick.org).
Run from the post directory:

```bash
# one PNG per card (post directory as root so the preamble import resolves)
typst compile --root . assets/carousel/_carousel.typ "assets/carousel/frame-{p}.png" --ppi 96

# assemble the looping GIF, then remove the frames
magick -delay 250 -loop 0 assets/carousel/frame-*.png -layers Optimize assets/carousel/carousel.gif
rm assets/carousel/frame-*.png
```
