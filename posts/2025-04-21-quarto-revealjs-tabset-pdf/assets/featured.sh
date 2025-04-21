#!/usr/bin/env bash

mkdir -p screenshots
npx -y decktape reveal \
  --chrome-arg=--no-sandbox \
  --chrome-arg=--disable-setuid-sandbox \
  --fragments \
  --screenshots \
  --screenshots-format png \
  --screenshots-directory screenshots \
  --size "1280x640" \
  _demo-tabset.html _demo-tabset-2.pdf && rm -f _demo-tabset-2.pdf

magick \
  -delay 75 \
  screenshots/_demo-tabset*.png \
  -loop 0 \
  -duplicate 1,-2-1 \
  -layers OptimizePlus \
  -colors 256 \
  -quality 85 \
  ../featured.gif
