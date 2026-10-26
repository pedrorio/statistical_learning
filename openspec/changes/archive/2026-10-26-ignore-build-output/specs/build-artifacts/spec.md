# Spec Delta

## Purpose

Keep knitr and LaTeX products out of the git index so a rebuild does not become a commit.

## ADDED Requirements

### Requirement: PDF is not tracked
`main.pdf` MUST NOT be tracked by git. Removing it from the index MUST NOT rewrite history.

#### Scenario: Untracked PDF
- **WHEN** `git ls-files main.pdf` runs after this change
- **THEN** it prints nothing and the working tree may still contain `main.pdf`

### Requirement: Build intermediates are ignored
Git MUST ignore `main.pdf`, `main.tex`, and LaTeX intermediates with suffixes `aux`, `log`, `toc`, `out`, `bbl`, `blg`, `fls`, `fdb_latexmk`, `synctex.gz`, `lof`, `lot`, and `xdv`. Generated `figure` and `cache` directories MUST stay ignored.

#### Scenario: Intermediate files are ignored
- **WHEN** a report build writes `main.tex` and `main.aux`
- **THEN** git ignores those paths and ignores `main.pdf`
