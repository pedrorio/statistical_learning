# Proposal

## Why

The re-evaluation's numbers depend on guarantees that were never written down as requirements or checked directly: tuning stays inside the training split, the cut-off comes from out-of-fold predictions, the metrics and the guess-low baseline follow their definitions, paired differences match splits, stored fits reproduce, and the graded files stay untouched. A regression in any of them would change the report without failing a check.

## What Changes

Size: S. The guarantees are added to `extended-reevaluation`, each with a scenario naming the test that checks it. Tests only: no code, result file, or graded artifact changes, and modelling results are not allowed to change.

- New tests: `tests/test_existing_{metrics,score_cut,paired,reproduction,training,fit_helpers,graded}.R`.
- The training test runs `fit_job` on a 300-row subset with 2 by 2 folds and two-point grids. The real analysis keeps its 10 by 10 and its grids.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `extended-reevaluation`: Adds the guarantees above as requirements.

## Impact

- New files under `tests/` only. Each runs in under 30 seconds with `Rscript tests/<file>` from the repository root. Nothing under `results/` is written.
