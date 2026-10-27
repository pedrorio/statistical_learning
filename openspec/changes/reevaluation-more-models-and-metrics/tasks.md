# Tasks

## 1. Metrics and saved predictions

- [ ] 1.1 Save out-of-fold and test probabilities (predicted scores for the score models) on each new fit, and verify a finished summary file contains both.
- [ ] 1.2 Add average precision, and precision and recall for high at the chosen cut-off, beside balanced accuracy, ROC AUC, and plain accuracy. Verify the separable-data test still scores the positive class above chance and that the new columns are finite there.

## 2. LightGBM

- [ ] 2.1 Add the bonsai LightGBM spec with one thread, the five tuned arguments, a size-40 space-filling grid, and early stopping on an analysis-set hold-out. Add lightgbm and bonsai to `renv.lock` without changing locked versions. Verify `renv::status()` reports no other lockfile drift.
- [ ] 2.2 Fit it with class weights and without, on the filtered recipe, and verify a one-seed smoke uses the training split only for selection and writes both arms.

## 3. Fuller XGBoost

- [ ] 3.1 Add the fuller XGBoost search (tree_depth, learn_rate, min_n, mtry, loss_reduction, sample_size, trees fixed at 500, size 40) with and without class weights. Verify the existing nine-point XGBoost spec and its grid are unchanged.

## 4. Score models

- [ ] 4.1 Fit random forest, LightGBM, and penalised linear regression on the raw quality score. Select on balanced accuracy at score 6.5 inside the 10 by 10, then tune the score cut on out-of-fold predictions. Verify the test labels are scored once and the outer test rows are absent from the cut search.

## 5. Five-split run

- [ ] 5.1 Run the 35 outer jobs on seeds 2021–2025 with the existing 10 by 10 and the existing grids left in place. Record the wall time. Verify the new summary rows exist and the previous 105 per-fit files are byte-identical.
- [ ] 5.2 Extend `reevaluation/report.Rnw` with the new metrics and models, render `build/reevaluation.pdf`, and verify the committed `main.pdf` hash is unchanged.
