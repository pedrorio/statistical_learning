# Spec Delta

## Purpose

A clean clone of the wine classification report can fit the 15 model-recipe combinations once and render a PDF without replacing the graded report.

## ADDED Requirements

### Requirement: Summaries are fitted outside the knit
The fit entry point SHALL write one summary per active model and recipe combination under `results/fits/`. The classification section SHALL read those summaries and SHALL NOT call the model fitter.

#### Scenario: Knit after a fit
- **WHEN** `results/fits/manifest.rds` and each combination summary exist
- **THEN** knitting the classification section uses those summaries and does not tune a model

### Requirement: Unchanged combinations are not refit
A second fit SHALL load a combination summary when its recorded key matches the current model file, recipe file, shared inputs, seed, split, and cross-validation settings.

#### Scenario: Repeat fit
- **WHEN** `fit.R` runs again and no combination key has changed
- **THEN** each combination is loaded from its `.rds` file and `tune_grid` is not called for it

### Requirement: Parallel fits are reproducible
The parent process SHALL set the uniform RNG to L'Ecuyer-CMRG and seed 2020 before the train-test split. Worker processes SHALL receive distinct streams from that parent state via `mclapply` with `mc.set.seed` enabled.

#### Scenario: Same seed, same summaries
- **WHEN** the fit is repeated from an empty `results/fits/` directory on the same lockfile
- **THEN** each combination's test accuracy matches the previous run

### Requirement: The graded PDF is not the build output
The render command SHALL write the PDF to `build/main.pdf` and SHALL leave the committed `main.pdf` byte-for-byte unchanged.

#### Scenario: Render
- **WHEN** the report is rendered after summaries exist
- **THEN** `build/main.pdf` exists and the committed `main.pdf` hash is unchanged
