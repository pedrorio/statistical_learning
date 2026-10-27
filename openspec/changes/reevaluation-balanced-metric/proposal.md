# Proposal

## Why

The graded report selects on accuracy. 1382 of 1599 red wines are low quality, so guessing low scores 86.43% accuracy and balanced accuracy 0.5. The winsorise step also refits its center and scale on the rows it transforms, including labelled test rows. This change specifies a separate re-evaluation that selects on balanced accuracy, freezes those statistics on the training predictors, and compares ROSE, class weights, and a tuned threshold on repeated stratified splits. The committed PDF and its conclusion stay as graded.

## What Changes

Size: M. One new fit entry and one short write-up. The graded report is not retuned, and the three old feature recipes are not crossed with the new resampling arms.

- Add `reevaluation/fit.R`, `reevaluation/report.Rnw`, and a training-only winsorise step. Render `build/reevaluation.pdf`. Store tibble summaries under `results/reevaluation/`.
- Select grid points by mean 10 by 10 cross-validated balanced accuracy, with high quality as the event. Report ROC AUC. Do not select on it.
- Compare three mutually exclusive arms on the filtered predictors only: ROSE, class weights, and neither. Tune one decision threshold per arm on out-of-fold training probabilities after the grid is selected.
- Add ranger and xgboost beside logistic regression, the two SVMs, LDA, and FDA. Keep the existing grids and the 10 by 10 CV. The new models get their own 9-point grids, named below. That is not a cut of the grids Pedro kept.
- Repeat five stratified 80/20 splits (seeds 2021–2025, L'Ecuyer-CMRG). Score each test split once. A win is every split's test balanced accuracy above 0.5.
- Modelling results in the graded report and in `build/main.pdf` are not allowed to change. The re-evaluation is a new write-up, and its numbers are allowed to differ from Table 3.1. `README.md` is not part of this change.

### Requirements

1. The re-evaluation is a labelled write-up beside the graded report, and it does not edit `main.pdf`, the conclusion, `fit.R`, or `utils/recipes/step_recipe.R`.
2. Hyperparameters are selected on balanced accuracy; every model and arm reports a confusion matrix, balanced accuracy, ROC AUC, and the guess-low baseline.
3. Winsorise center and scale are learned on the training predictors only, pooled across classes, and bake does not read the outcome.
4. Each outer split is a seeded stratified 80/20 split; the 10 by 10 CV on the training split is the only model selection; the test split is scored once; the report shows the spread across five splits.
5. ROSE, class weights, and no resampling are mutually exclusive, each with a threshold tuned on out-of-fold training probabilities.
6. Random forest and gradient boosting sit beside the five current models, with their own grids; the current grids and the 10 by 10 CV stay.

### Planned outputs

- Table `ba-by-arm`: for all 7 models and 3 arms, plus a guess-low row, the mean, standard deviation, and minimum of test balanced accuracy across the five splits, the mean ROC AUC, the mean accuracy, and whether every split beat 0.5.
- Table `confusion`: mean test TP, FP, TN, and FN, high quality as the positive class, same rows.
- Table `selected`: for each split, the cross-validated parameters and the threshold chosen from training out-of-fold probabilities.
- Figure `ba-splits`: test balanced accuracy on each split, one panel per arm, with a line at 0.5.
- No per-grid performance plots, and no ggplot objects inside the `.rds` summaries.

The guess-low row predicts low on every test row. Its balanced accuracy is 0.5, its ROC AUC is 0.5, and its accuracy is that split's low rate. Stratification keeps that rate near 1382/1599, which the report's rounding prints as 86.43%.

### Protocol

Reuse the parallel shape from this branch: parent `RNGkind("L'Ecuyer-CMRG")`, `mclapply` with `mc.set.seed = TRUE`, workers that do not call `set.seed` or `RNGkind`, and `tune_grid` with `save_pred = FALSE` and `allow_par = FALSE`. Do not call `utils/estimation/pipeline.R`, because that function runs `last_fit` as soon as the grid is selected.

For each outer seed in 2021, 2022, 2023, 2024, and 2025: set the RNG kind, call `set.seed`, then `initial_split(prop = 0.8, strata = quality)`. On the training split only, `vfold_cv(v = 10, repeats = 10, strata = quality)`. Select the grid point by mean balanced accuracy at the hard 0.5 classification those predictions already use. Then `fit_resamples` that one workflow on the same folds, with predictions saved, and choose the threshold in `seq(0.01, 0.99, by = 0.01)` that maximises out-of-fold balanced accuracy. Fit that workflow once on the training split, apply the threshold to the test probabilities, and score the test split. Nested cross-validation is not used. The inner 10 by 10 already selects the grid; the five outer splits are the check on selection.

The filtered recipe keeps `step_naomit`, `step_zv`, `step_nzv`, `step_corr(threshold = 0.80)`, `step_lincomb`, and the fixed winsorise step. It does not standardise and it does not run PCA. ROSE is `themis::step_rose` on that recipe and nowhere else. The weight arm and the plain arm omit ROSE.

### Class weights

Checked on the lockfile's parsnip 1.6.1 and discrim 1.1.0. glmnet, ranger (`case.weights`), xgboost, mda LDA, and earth FDA protect a weights argument, so those five use `workflows::add_case_weights` with inverse-frequency `hardhat::importance_weights` computed on the outer training split: weight for class c is `n / (2 * n_c)`. The kernlab SVM fit modules do not map case weights. `ksvm` does accept a named `class.weights` vector, so the two SVMs receive that vector from the same training split through `set_engine`. If a smoke fit shows the argument is ignored, that SVM weight cell is `unsupported`, not a silent unweighted score. Weights are not recomputed on the test rows and are not recomputed inside each fold.

### New grids

Pedro rejected cutting the 10 by 10 CV and the existing grids for speed. Those stay: logistic regression 5 by 5 on penalty and mixture, polynomial SVM 3 levels on degree, scale, and cost, radial SVM 5 levels on sigma and cost, LDA 5 penalties, FDA `grid = 5`. Ranger and xgboost are not in the lockfile and need grids of their own:

- Random forest: `parsnip::rand_forest(mtry = tune(), min_n = tune(), trees = 500)`, engine ranger, `num.threads = 1`, `grid_regular` of `mtry()` and `min_n()` at 3 levels (9 points).
- Gradient boosting: `parsnip::boost_tree(trees = 500, tree_depth = tune(), learn_rate = tune(), min_n = 10)`, engine xgboost, `nthread = 1`, `grid_regular` of `tree_depth()` and `learn_rate()` at 3 levels (9 points).

Nine points is smaller than the radial SVM grid (25) and the polynomial SVM grid (27). It is a new grid, not a thinning of an old one. Thread caps stay at 1 because the only parallelism is the combination-level `mclapply`.

### Winsorise

The graded bake calls `robustHD::winsorize` on a data.frame with `prob = 0.999`. The data.frame method passes those extra arguments to `as.matrix`, so `0.999` never reaches the worker. The worker is the multivariate method at its default probability 0.95: median, MAD, a Huber correlation, and a chi-square shrink. A one-column call would have ignored `prob` and capped the robust z-score at 2; that is not the call in the bake.

The re-evaluation step, in a new file, stores that multivariate transform from the training predictors, pooled across classes, and bake applies the stored values. Bake does not read the outcome and does not recompute the correlation on the new rows. `utils/recipes/step_recipe.R` stays as it is, because that file is in the original fit cache key and the graded path keeps its historical step.

### Runtime

The measured full fit on this branch is the anchor: 15 combinations, 4 cores, `mclapply` 1795.0 seconds, bash elapsed 1801.3 seconds. Six of those jobs are the two kernlab SVMs. One outer split here has those same six SVM jobs (two kernels times three arms) plus fifteen others (logistic regression, LDA, FDA, ranger, and xgboost, times three arms). Wall time per split should sit near that 1801 second measurement, plus whatever the two new 9-point grids add once the SVM jobs release the cores. Five splits, run one after another on 4 cores, are about 2.5 to 4 hours. That is an estimate from the measured run, not a new timing. Ten outer splits, nested CV, or crossing in the standardised and PCA recipes would multiply the SVM work and is not the design.

### Risks

- Adding ranger and xgboost changes `renv.lock`, which is in the original cache key, so `results/fits/` misses once. Do not bump any package already locked. A refit of the original 15 should follow the same seed and the same code; this change must not edit that code to force the miss.
- kernlab may ignore `class.weights` passed through `set_engine`. The cell is then unsupported.
- FDA on earth can still fail to predict, as the standardised recipe did under seed 2020. Record `NA`. Do not impute.
- Saving predictions for every grid point is what the fast build turned off. Save them only for the one selected workflow.
- ROSE draws random samples inside the recipe. Reproducibility depends on the parent L'Ecuyer stream and `mc.set.seed`, not on a seed inside the worker.
- The re-evaluation will not match Table 3.1. The first paragraph of the write-up has to say that, and that it is not the graded conclusion.
- Inverse-frequency weights use the outer training split, not each fold. Stratified folds make the difference small, and the test split is not involved.
- Ranger and xgboost default to several threads. Leaving that on would oversubscribe the four `mclapply` workers.

### Open questions

Each one is closed here by the recommendation. Gate 1 can send a choice back; the spec below records these recommendations so an approval is implementable.

- Balanced accuracy or ROC AUC for selection? Balanced accuracy. The decision is a hard label, the baseline is a hard guess-low classifier, and the threshold is part of the question. AUC stays in the table because it does not depend on the threshold.
- Five or ten outer splits? Five. Ten doubles a multi-hour run and is not needed to see the spread.
- Nested CV? No. The inner 10 by 10 selects the grid. The outer splits are the honesty check.
- Include the standardised and PCA recipes? No. The question is which models beat guess-low under an honest resampling comparison. Those recipes stay in the original report.
- What grids do the new models get? Their own 9-point grids, above. The existing grids are not reduced. Pedro already rejected cutting them for speed.
- What if an engine cannot take class weights? Mark that cell unsupported. Do not fall back to ROSE and do not report an unweighted fit as the weight arm. On the current lockfile only the kernlab SVMs need the `class.weights` path.
- Pooled training limits or per-class training limits? Pooled. Per-class limits need the label at transform time, which is the leak.
- Threshold inside the grid or after it? After `select_best`, on that workflow's out-of-fold probabilities. Putting it in the grid requires predictions for every candidate.
- Where does the write-up live? `reevaluation/report.Rnw` and `build/reevaluation.pdf`. Do not edit `README.md` here; the uncommitted `readme-state-the-result` draft already owns that file.

## Capabilities

### New Capabilities

- `balanced-reevaluation`: A separate, repeated-split comparison of the current classifiers plus ranger and xgboost, scored on balanced accuracy against guessing low.

### Modified Capabilities

- None. The graded-path fit, its metric, its split, and its winsorise step are unchanged.

## Impact

- New files under `reevaluation/`, summaries under `results/reevaluation/`, and `build/reevaluation.pdf`.
- `renv.lock` gains ranger, xgboost, and any new dependencies. Existing locked versions stay.
- No edits to `main.pdf`, `conclusion/`, `README.md`, `fit.R`, `utils/estimation/pipeline.R`, `utils/recipes/step_recipe.R`, or the original model and recipe files.
