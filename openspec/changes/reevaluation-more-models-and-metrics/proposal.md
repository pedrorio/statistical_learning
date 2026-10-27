# Proposal

## Why

The re-evaluation reports balanced accuracy, ROC AUC, and plain accuracy, but not whether the high calls are precise, and it does not keep the probabilities a later stack would need. Boosting is a nine-point grid, and every model classifies the high/low label, so a model of the raw quality score has not been compared on the same splits. This change adds average precision, precision, and recall, saves the probabilities, and adds LightGBM, a larger XGBoost search, and three score models. Graded results must not change. The new re-evaluation numbers may.

## What Changes

Size: M. Thirty-five new outer fits and a wider metrics table. The existing 10 by 10 is not rerun. A one-shot refit of each already selected workflow may write test probabilities for the original 105 fits to new files. The light nine-point XGBoost arm stays as it is.

- Save out-of-fold and test-set probabilities for every fit this change runs. Score models save the numeric prediction in that same place.
- Add average precision, and precision and recall for high at the chosen cut-off, next to balanced accuracy, ROC AUC, and plain accuracy.
- Add LightGBM (`parsnip::boost_tree`, bonsai `lightgbm` engine) with and without class weights. Tune trees, learn_rate, num_leaves, min_n, and the feature fraction. Forty space-filling candidates. Early stopping uses a hold-out cut from the analysis set of each resample.
- Add a fuller XGBoost search with the same forty candidates, with and without class weights. It also tunes min_n, mtry, loss_reduction, and sample_size, on top of tree_depth and learn_rate. Trees stay at 500. The existing nine-point arm, including its ROSE cell, is not replaced.
- Add three models of the raw quality score (3–8): random forest, LightGBM, and penalised linear regression. The predicted score is the ranking. Inside the 10 by 10, high means predicted score at least 6.5. After the candidate is chosen, the cut on the score is tuned on out-of-fold predictions and applied once to the test scores.

### Invariants

Same five seeds, 2021–2025, and the same stratified 80/20 splits. The 10 by 10 cross-validation on the training split is the only model selection, and it selects on balanced accuracy. The cut-off is chosen from out-of-fold predictions. The test set is scored once. Existing grids stay, including both SVMs and the polynomial SVM, and the 10 by 10 CV is not shrunk. `main.pdf`, the graded conclusion, `fit.R`, and `utils/recipes/step_recipe.R` are not edited.

### Out of scope

Later changes, not this one: GAM or spline logistic regression; a stacked ensemble (the saved out-of-fold probabilities are what that stack will use); TabPFN.

### New fits

Thirty-five outer jobs, five seeds each:

- LightGBM classification, class weights and none: 10.
- Fuller XGBoost, class weights and none: 10.
- Score models, random forest, LightGBM, and penalised linear, one arm each: 15.

No ROSE on the new jobs. Class weights stay the training-split inverse-frequency weights `n / (2 * n_c)`. A new engine that ignores those weights is `unsupported`, not a silent unweighted score.

### Runtime

The per-fit `.rds` mtime is when that job finished. `run.rds` records the original `mclapply` at 38124.9 seconds on 4 cores. The original start is the mtime of `fda__weights__2025.rds` minus that wall time (2026-10-26 20:25:25 UTC). Jobs ran in seed, then arm (`rose`, `weights`, `none`), then model order, with `mc.preschedule = FALSE`. A job's duration is its mtime minus the time a worker became free.

The ten class-weight SVM files were rewritten by the probability fix. Their durations come from that refit, whose own mtimes and 1182.1 second wall time recover all ten: 382 to 423 seconds. Inserting those durations into the original queue makes the other cells readable. A reconstructed duration more than three times the shortest of the same model and arm is a scheduling collision (this hits some 2023 and 2024 cells) and is not used.

The anchor for a nine-point boost is the class-weight XGBoost cell. All five seeds survived that rule: 253, 254, 259, 272, and 330 seconds, median 259. One candidate's 10 by 10 therefore costs 259/9 seconds. Forty candidates cost 1151 seconds for one outer job. Thirty cost 863 seconds and fifty cost 1439. The random-forest anchor is the class-weight forest, all five seeds between 362 and 418 seconds, median 376, for its existing nine-point grid. The penalised-linear anchor is logistic regression with no resampling, median 70 seconds, for the penalty by mixture grid it already uses.

CPU sum at forty candidates: 25 search jobs times 1151 seconds (the twenty classification searches and five score LightGBM jobs), plus 5 times 376 and 5 times 70. That is 31005 seconds. On 4 cores that is 7751 seconds, 2.15 hours, if the cores stay busy. At thirty candidates the same sum is 5951 seconds, 1.65 hours; at fifty, 9551 seconds, 2.65 hours. End-of-queue idle is at most about one search job, 1151 seconds, and is not inside the 7751. LightGBM early stopping is not given a discount, so its share is an upper bound copied from the measured 500-tree XGBoost. Saving the selected out-of-fold and test predictions does not add a grid.

## Capabilities

### New Capabilities

- `extended-reevaluation`: Saved probabilities, average precision, precision and recall, LightGBM, the fuller XGBoost search, and the raw-score models, on the existing five-split protocol.

### Modified Capabilities

- None. `balanced-reevaluation` is the current change's spec and is not in `openspec/specs/` yet. This change does not edit that spec. The light XGBoost arm and the existing grids keep their current behavior.

## Impact

New code stays under `reevaluation/`. `renv.lock` gains lightgbm and bonsai only; versions already locked are not bumped. Summaries stay in `results/reevaluation/`. The write-up remains `reevaluation/report.Rnw`. Graded files are untouched.
