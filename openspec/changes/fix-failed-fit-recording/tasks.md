# Tasks

## 1. Acceptance tests

- [x] 1.1 Add `tests/test_failed_fit_recording.R`, `tests/test_failed_fit_training.R`, and `tests/test_guess_low_stored_pr_auc.R`, and show that they fail on the current code.

## 2. Fix (after Gate 1)

- [ ] 2.1 Read the tag and name before building the row in `empty_metrics()`.
- [ ] 2.2 Store the guess-low PR AUC as the test share of high in `refit_pr_auc.R`, and update `guess_low_pr_auc` in `run_pr_original.rds` without changing any other stored value.
- [ ] 2.3 Run every test, and check that `main.pdf` and the per-fit files are unchanged.
