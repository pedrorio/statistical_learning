# Proposal

## Why

Every accuracy in the report is one test-set percentage. The training grid already stores a mean and a standard error, and the classes are unbalanced, but neither a spread nor a per-class metric is printed. This change is spec-only. It is not implemented in this PR.

## What Changes

No code changes.

## Current code

The current code does **not** satisfy this proposal.

- `get_model_fit()` returns `fit$test$metrics[1,][[".estimate"]]`. The Rnw prints that value as a percentage. `accuracy_table()` does the same for every model-recipe pair. Table 3.1 in the September 2020 report is those point estimates (radial SVM on the filtered dataset is 84.95%). No cell is a mean ± standard deviation or a confidence interval.
- `pipeline()` does keep `results %>% collect_metrics()` on `train$metrics`. For a tune grid that object has a mean and a standard error across resamples. No chunk prints them. `autoplot(results)` draws the grid. It is not a numeric interval in the text.
- `pipeline()` builds train and test confusion matrices with `conf_mat(truth = quality, estimate = .pred_class)`. The Rnw does not print them. There is no sensitivity, specificity, or per-class accuracy.
- The natural slice is `quality` (`low` and `high`). Section 2.1 says 1382 observations are low and 217 are high. No metric is broken out by that class.
- `type` is the constant factor `red`, so wine colour is not a slice of the fitted table. `data/winequality-white.csv` is not loaded.

## Capabilities

### New Capabilities

- `uncertainty`: Report a spread with each accuracy, and a metric on each quality class.

### Modified Capabilities

- None. This change is not applied.

## Impact

None in this PR. A later implementation would change `get_model_fit()`, the accuracy table, and the Rnw chunks that print a single percentage.
