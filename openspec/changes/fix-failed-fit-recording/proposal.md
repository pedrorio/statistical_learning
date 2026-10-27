# Proposal

## Why

`empty_metrics()` builds its row with `tibble(model = model$tag, model_name = model$name, ...)`. Inside `tibble()` the new `model` column masks the `model` argument, so `model$name` fails with `$ operator is invalid for atomic vectors`. Every fit that should be recorded as `unsupported` or `na` crashes instead, and in `fit_reevaluation()` that crash stops the whole run. The balanced re-evaluation already promises that such a fit is stored as `NA` or `unsupported`; the code cannot do it. No stored fit hit this path: all 140 are `ok`.

`reevaluation/refit_pr_auc.R` (lines 311–317) stores the guess-low PR AUC in `run_pr_original.rds` as `pr_auc_vec` of a constant score. That is the trapezoid (1 + 44/321) / 2 = 0.569, not the test prevalence 44/321 = 0.137. The report computes 0.137 itself and does not read the stored value, so only the stored artifact is wrong.

## What Changes

Size: XS. No reported number changes, and modelling results are not allowed to change.

- `empty_metrics()` reads the tag and name before building the row.
- `refit_pr_auc.R` stores the guess-low PR AUC as the test share of high, and `run_pr_original.rds` gets that value; every other field stays as stored.
- Acceptance tests: `tests/test_failed_fit_recording.R`, `tests/test_failed_fit_training.R`, `tests/test_guess_low_stored_pr_auc.R`. All three fail before the fix.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `extended-reevaluation`: Failed and unsupported fits are recorded rather than fatal, and the stored guess-low PR AUC is the prevalence.

## Impact

- `reevaluation/fit_reevaluation.R` and `reevaluation/refit_pr_auc.R`. Editing `fit_reevaluation.R` changes the source md5 in the cache key, so the added fits would miss the cache on a rerun. This change does not rerun them.
- `results/reevaluation/run_pr_original.rds`: only `guess_low_pr_auc` changes. No per-fit file, summary table, or graded file changes.
