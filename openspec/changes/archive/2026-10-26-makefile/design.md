# Design

## Context

See proposal.md. `knitr.zsh` runs `knit2pdf`, then both `lualatex` and `pdflatex`, then `bibtex` twice. The committed PDF's producer is pdfTeX, so the last successful engine was pdflatex.

## Goals / Non-Goals

**Goals:**

- One `make report` that yields `main.pdf`.
- `make test` runs the existing helper without fitting the full grid.

**Non-Goals:**

- Changing the knitr document or the model code.
- Opening the PDF in a GUI.

## Decisions

- `tinytex::latexmk(..., engine = "pdflatex")` runs pdflatex and bibtex and installs missing TeX packages in CI. That replaces the hand-rolled `lualatex` / `pdflatex` / `bibtex` sequence.
- `make test` changes directory only after `libraries.R` has run, because `test_pipeline.R` sources `./pipeline.R`.

## Risks / Trade-offs

- [`latexmk` pulls TeX packages on first run] → `setup-tinytex` plus the `tinytex` R package is in the lockfile.
- [The test target does not fit a model] → That matches `test_pipeline.R`, which only defines a function.

## Migration Plan

Use `make deps`, `make test`, and `make report`. `knitr.zsh` is removed.
