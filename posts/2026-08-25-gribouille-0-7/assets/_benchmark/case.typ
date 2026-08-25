#import PACKAGE: *
#set page(width: auto, height: auto, margin: 0pt)

// Deterministic pseudo-random data, identical under both versions.
#let lcg(seed, n) = {
  let out = ()
  let s = seed
  for _ in range(n) {
    s = calc.rem(s * 1103515245 + 12345, 2147483648)
    out.push(s / 2147483648)
  }
  out
}

#let n = NROWS
#let xs = lcg(7, n)
#let ys = lcg(13, n)
#let data = range(n).map(i => (
  x: xs.at(i) * 100,
  y: ys.at(i) * 100,
  g: ("a", "b", "c", "d", "e").at(calc.rem(i, 5)),
))

#plot(
  data: data,
  mapping: MAPPING,
  layers: (LAYER,),
  width: 10cm,
  height: 6cm,
)
