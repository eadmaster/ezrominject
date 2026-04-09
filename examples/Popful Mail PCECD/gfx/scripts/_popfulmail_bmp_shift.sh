#!/bin/bash

imconvert "$1" -background black -flatten \
    -gravity Center -extent 64x16 +repage \
    -crop 8x16 +repage \
    \( -clone 0 -gravity North -splice 0x3 -gravity South -chop 0x3 \) \
    \( -clone 1 -gravity North -splice 0x2 -gravity South -chop 0x2 \) \
    \( -clone 2 -gravity North -splice 0x3 -gravity South -chop 0x3 \) \
    \( -clone 3 -gravity North -splice 0x2 -gravity South -chop 0x2 \) \
    \( -clone 4 -gravity North -splice 0x3 -gravity South -chop 0x3 \) \
    \( -clone 5 -gravity North -splice 0x2 -gravity South -chop 0x2 \) \
    \( -clone 6 -gravity North -splice 0x3 -gravity South -chop 0x3 \) \
    \( -clone 7 -gravity North -splice 0x2 -gravity South -chop 0x2 \) \
    -delete 0-7 \
    +append \
    -colors 2 -depth 1 -type Bilevel +repage "$2"