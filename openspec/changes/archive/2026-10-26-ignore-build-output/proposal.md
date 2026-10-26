# Proposal

## Why

`main.pdf` is a knitr and LaTeX product. It is tracked today, so every rebuild dirties the history. Generated TeX and LaTeX intermediates should stay out of git as well. History is not rewritten.

## What Changes

- `git rm --cached main.pdf` so the file leaves the index and stays on disk.
- Ignore `main.pdf`, `main.tex`, and LaTeX intermediates (`*.aux`, `*.log`, `*.toc`, `*.out`, `*.bbl`, `*.blg`, `*.fls`, `*.fdb_latexmk`, `*.synctex.gz`, `*.lof`, `*.lot`, `*.xdv`).
- Keep `figure/` and `cache/` ignored. They are already ignored.
- Do not rewrite history and do not force-push.
- Do not change models or the report source.

## Current code

Before this change the repository does **not** satisfy this proposal. `main.pdf` is tracked. `.gitignore` ignores `cache` and `figure` but not `main.pdf` or `main.tex`.

## Capabilities

### New Capabilities

- `build-artifacts`: Generated report files are not tracked.

### Modified Capabilities

- None.

## Impact

- `main.pdf` becomes untracked. `.gitignore` gains the patterns above.
