# Proposal

## Why

The held-out split is drawn without its own seed, then every model is scored on it, and the report picks the preferred models from those test accuracies. Tuning itself stays on the training folds. This change is spec-only. It is not implemented in this PR.

## What Changes

No code changes. The requirements below are the target. The current pipeline is not modified.

## Current code

The current code does **not** satisfy this proposal.

- `classification_and_discrimination.R` calls `rsample::initial_split(data, prop = .8)` with no seed argument and no `strata`. `rsample::initial_split` in the lockfile has no `seed` parameter (`data`, `prop`, `strata`, `breaks`, `pool`, `...`). `libraries.R` now ends with `set.seed(2020)`, and the classification setup chunk sources that loader before the split, so the next RNG draw is deterministic. That is not the same as one split object created with a fixed seed and then left alone: a later edit that draws random numbers between the loader and `initial_split` moves the split, and a saved `results/classification_and_discrimination_fits.Rda` skips the split entirely.
- Tuning does stay inside training. `vfold_cv(train_data, v = 10, repeats = 10, strata = quality)` is built from the training portion only. `tune_grid` receives those folds. `select_best(metric = "accuracy")` reads that grid. The test rows are not an input to `tune_grid`. This part is already true.
- The test set is not used exactly once. `pipeline()` calls `tune::last_fit(data_split)` for every active model-recipe pair: `lr`, `svm_poly`, `svm_radial`, `lda`, and `fda`, each with `fd`, `sfd`, and `sfpc` (15 calls). `get_model_fit()` and `accuracy_table()` read `test$metrics`. Section 3.0.6 of `classification_and_discrimination.Rnw` compares those test accuracies and names the radial SVM, logistic regression, and flexible discriminant analysis as the better methods. The test set therefore influences which model the report treats as best.
- The same Rnw hardcodes penalty, mixture, cost, degree, and sigma in the prose (for example "a penalty of 1 and a mixture of 50%"). Those sentences are not read from `select_best`. They can disagree with the fit that was actually selected.
- The split is not stratified. Section 2.1 says 1382 wines are low quality and 217 are high. The folds are stratified on `quality`. The test split is not.

## Capabilities

### New Capabilities

- `locked-test-split`: One seeded split, training-only tuning, and a single final test evaluation.

### Modified Capabilities

- None. This change is not applied.

## Impact

None in this PR. A later implementation would edit the classification chunk and the way `pipeline()` calls `last_fit`.
