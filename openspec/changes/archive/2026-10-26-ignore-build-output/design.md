# Design

## Context

See proposal.md. `knitr.zsh` already deleted `*.aux`, `*.toc`, `*.log`, `*.out`, `*.tex`, and bibliography files after a local build, then left `main.pdf` behind. That PDF is in the git index.

## Goals / Non-Goals

**Goals:**

- Stop tracking build output without rewriting history.

**Non-Goals:**

- Deleting `main.pdf` from past commits.
- Ignoring hand-written `.Rnw` or `.bib` files.

## Decisions

- `git rm --cached main.pdf` untracks the current file only.
- Ignore `main.tex` by name rather than every `*.tex`, so a future source file is not swept up. Other LaTeX suffixes are ignored with the globs listed in the proposal.
- `figure` and `cache` stay ignored as they already are.

## Risks / Trade-offs

- [Clones no longer contain a PDF until `make report`] → CI uploads `main.pdf` as an artifact, and a `v*` tag attaches it to the release.

## Migration Plan

After pulling, run `make report` to regenerate the PDF. No data migration.
