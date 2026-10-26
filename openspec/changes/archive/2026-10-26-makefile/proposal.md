# Proposal

## Why

`knitr.zsh` is a zsh script that calls `open main.pdf` and is not what CI can run. The report, the test helper, restore, and cleanup need Make targets.

## What Changes

- Add a Makefile with `report`, `test`, `deps`, and `clean`.
- `make report` knits `main.Rnw` and runs pdflatex through `tinytex::latexmk`.
- `make test` sources `libraries.R` and then `utils/estimation/test_pipeline.R`.
- `make deps` runs `renv::restore`.
- `make clean` deletes the PDF, the generated `main.tex`, LaTeX intermediates, `figure/`, and `cache/`.
- Delete `knitr.zsh`.
- Do not change models, recipes, the split, or the metric.

## Current code

Before this change the repository does **not** satisfy this proposal. The only build entry point is `knitr.zsh`. There is no Makefile. `test_pipeline.R` is not invoked by a target.

## Capabilities

### New Capabilities

- `makefile`: Build, test, restore, and clean targets that replace `knitr.zsh`.

### Modified Capabilities

- None.

## Impact

- New `Makefile`. Deleted `knitr.zsh`.
- The README points at these targets in the `readme` change.
