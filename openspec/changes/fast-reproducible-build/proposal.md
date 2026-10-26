# Proposal

## Why

A fresh clone cannot rebuild the report. Fitting runs inside the knit, so every render refits all 15 combinations, and `libraries.R` sources `renv/activate.R`, which is not in the tree.

## What Changes

- Fit the 15 model-recipe combinations in `fit.R`. Each combination writes one summary under `results/fits/` (test accuracy, selected parameters, and the hyperparameter plot). The knit reads those summaries and does not fit.
- Refit a combination only when its source files, the red CSV, `renv.lock`, or the recorded split and CV settings change.
- Run the combinations with `parallel::mclapply` (`mc.set.seed = TRUE`). `RNGkind("L'Ecuyer-CMRG")` and `set.seed(2020)` run once in the parent, before the split and the folds.
- Load packages from the `main.Rnw` setup chunk. Drop packages nothing calls: factoextra, NbClust, mclust, amap, vegan, fpc, RSNNS, randomGLM, HDclassif, hda, robustDA, arm, vip, matlib, xtable, doParallel, data.table, dtplyr.
- Render each figure with knitr's default single device. Replace the `knit2pdf` plus six LaTeX passes with `knitr::knit` and one `latexmk -pdf`, writing `build/main.pdf`.
- Commit `renv.lock`, `renv/activate.R`, and `.Rprofile`. Fix `ssource`. Create `results/` when fitting. Replace `recipes::terms_select` with `recipes::recipes_eval_select`.
- Keep the same model settings on current packages: syntactic names via `make.names` (`janitor::set_tidy_names` is gone), discriminant specifications from `parsnip`, `select_best(metric = "accuracy")`, and `step_pca(..., options = list(...))`. Workers tune with `allow_par = FALSE` so the only parallelism is the combination-level `mclapply`.
- Read the accuracy row from `last_fit` (current tune also returns ROC AUC and Brier). The comparison table is built in-process. If a final fit produces no predictions, that cell is `NA`. With seed 2020 this happens for flexible discriminant analysis on the standardised recipe: `num_terms = 1`, `prod_degree = 1`, and earth reports no terms component.
- Modelling results are allowed to differ from graded Table 3.1 because the fit is seeded and the packages are current. The split (80%, not stratified), the accuracy metric, winsorising at 0.999, ROSE, the grids, and the 10 by 10 stratified CV do not change. The committed `main.pdf` is not replaced.

## Capabilities

### New Capabilities

- `reproducible-build`: A clean clone fits one summary per model-recipe combination and renders a PDF beside the graded report.

### Modified Capabilities

- None.

## Impact

- `fit.R`, `knitr.zsh`, `main.Rnw`, the classification chunk, package list, `renv.lock`, `.gitignore`, and the winsorise prep step.
- `results/` and `build/` stay untracked. `main.pdf` stays the graded file.
