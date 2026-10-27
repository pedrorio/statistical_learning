# Tasks

## 1. Training-only winsorise

- [x] 1.1 Add a re-evaluation winsorise step that stores the training median, MAD, and Huber correlation, pooled across classes, and applies them without reading the outcome. Leave `utils/recipes/step_recipe.R` unchanged.
- [x] 1.2 Verify that baking the training frame matches `robustHD::winsorize` on that frame, and that removing or permuting the outcome does not change the predictors.

## 2. Arms, weights, and new models

- [x] 2.1 Add the filtered recipe three ways: ROSE, inverse-frequency weights, and neither. Keep ROSE and weights off the same arm. Pass kernlab a named `class.weights` vector from the training split.
- [x] 2.2 Add ranger and xgboost specs with the 9-point grids and one thread. Do not edit the five existing model files or their grids. Add the packages to `renv.lock` without changing versions already locked.
- [x] 2.3 Correct the class-weighted kernlab probability columns so the high-class probability follows the decision value. Cover it with a separable SVM test.

## 3. Fit and report

- [x] 3.1 Fit five stratified outer splits, seeds 2021–2025, with 10 by 10 inner CV, balanced-accuracy selection, an out-of-fold threshold, and one test score. Write tibble summaries under `results/reevaluation/` with `mclapply`. Do not call `pipeline()` and do not write `results/fits/`.
- [x] 3.2 Render `reevaluation/report.Rnw` to `build/reevaluation.pdf` with the three tables, the split figure, the guess-low row, and an opening paragraph that separates it from the graded conclusion. Verify the committed `main.pdf` hash is unchanged.
