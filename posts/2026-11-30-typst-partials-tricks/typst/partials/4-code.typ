// 4. Code: no ligatures, no page break inside a block, light background.
#show raw: set text(ligatures: false, features: ("calt": 0))
#show raw.where(block: true): set block(
  width: 100%, fill: tint, inset: 0.8em, radius: 4pt, breakable: false,
)
