# Spec Delta

## Purpose

Give the report, the pipeline helper, package restore, and cleanup a single set of Make targets.

## ADDED Requirements

### Requirement: Report target
`make report` MUST knit `main.Rnw` to `main.tex` and MUST compile that file to `main.pdf` with pdflatex.

#### Scenario: Report command
- **WHEN** `make report` finishes
- **THEN** `main.pdf` exists and was produced from `main.Rnw`

### Requirement: Test target
`make test` MUST source `libraries.R` and then `utils/estimation/test_pipeline.R` from that file's directory.

#### Scenario: Test command
- **WHEN** `make test` runs
- **THEN** it sources `utils/estimation/test_pipeline.R` after the loader and exits 0

### Requirement: Dependency target
`make deps` MUST restore packages from `renv.lock` with `renv::restore`.

#### Scenario: Restore command
- **WHEN** `make deps` runs
- **THEN** it calls `renv::restore` on the lockfile

### Requirement: Clean target
`make clean` MUST remove `main.pdf`, generated `main.tex`, LaTeX intermediate files, and the `figure` and `cache` directories.

#### Scenario: Clean command
- **WHEN** `make clean` runs after a report build
- **THEN** `main.pdf`, `main.tex`, `figure/`, and `cache/` are gone

### Requirement: Knitr script removed
The repository MUST NOT contain `knitr.zsh`.

#### Scenario: Script is absent
- **WHEN** the repository tree is listed
- **THEN** `knitr.zsh` is not present
