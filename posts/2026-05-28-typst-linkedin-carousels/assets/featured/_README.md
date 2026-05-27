# featured.typ

Source for the post's social card, `featured.png` (1200 by 630), kept at the post root.

It is self-contained and does not import `_preamble.typ`.
Rebuild it from the post directory:

```bash
typst compile assets/featured/featured.typ featured.png --ppi 127
```
