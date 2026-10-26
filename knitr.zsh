#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
graded=$(md5sum main.pdf | awk '{print $1}')
Rscript -e 'knitr::knit("main.Rnw", output = "build/main.tex")'
latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=build build/main.tex
after=$(md5sum main.pdf | awk '{print $1}')
if [ "$graded" != "$after" ]; then
  echo "build changed the graded main.pdf" >&2
  exit 1
fi
