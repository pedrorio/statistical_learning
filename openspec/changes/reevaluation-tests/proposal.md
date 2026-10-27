# Proposal

## Why

The re-evaluation's numbers rest on code with few direct tests: the metric arithmetic, the score-model cut, the paired differences against the radial SVM, the split and weight helpers, the cache and protected-path guards, and the claim that the 105 stored fits can be refit exactly. A regression in any of them would change the report without failing a check.

## What Changes

Size: S. Tests only. No code, result file, or graded artifact changes, and modelling results are not allowed to change.

- `tests/test_existing_metrics.R`: balanced accuracy, ROC AUC, PR AUC, the first-maximum threshold, the score ranking, the guess-low row, and the 6.5 cut, on hand-computed cases.
- `tests/test_existing_score_cut.R`: on one small split, the score model is selected by the fixed 6.5 cut on per-fold refits, the test cut comes from out-of-fold scores, and perturbing the test rows moves neither.
- `tests/test_existing_paired.R`: runs the report's `load` chunk and checks the per-split differences, their sign, matching by seed, the sample sd, and the guess-low PR AUC of 44/321.
- `tests/test_existing_reproduction.R`: refits five sampled original fits from stored hyperparameters and matches the stored test metrics within 1e-9.
- `tests/test_existing_fit_helpers.R`: split, fold, and weight properties, the out-of-fold leakage guard, protected paths, cache keys, and the stored added-fit files.
- `tests/test_existing_graded.R`: `fit.R`, `utils/recipes/step_recipe.R`, `conclusion/`, and `main.pdf` are unchanged since b86768e.

## Capabilities

### New Capabilities

- `reevaluation-tests`: Fast characterisation tests for the existing re-evaluation.

### Modified Capabilities

- None.

## Impact

- New files under `tests/` only. Each runs in under 30 seconds with `Rscript tests/<file>` from the repository root. Nothing under `results/` is written.
