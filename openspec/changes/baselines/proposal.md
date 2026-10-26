# Proposal

## Why

The report's best test accuracy is a single percentage with no null classifier and no plain logistic model beside it. The classes are unbalanced (1382 low, 217 high in section 2.1), so accuracy without a majority baseline is hard to read. This change is spec-only. It is not implemented in this PR.

## What Changes

No code changes.

## Current code

The current code does **not** satisfy this proposal.

- There is no null model, no majority-class classifier, and no `parsnip::null_model()`. Nothing in the report places a baseline accuracy next to the fitted models.
- The logistic model is not plain. `lr` is `logistic_reg(penalty = tune(), mixture = tune())` on the glmnet engine, with `grid_regular` over penalty and mixture at 5 levels. It is an elastic net, not an unpenalised logistic regression.
- `lda` is `discrim_linear(penalty = tune())` on the mda engine with a 5-level penalty grid. It is not an unpenalised linear classifier.
- The fitted list is `lr`, `svm_poly`, `svm_radial`, `lda`, and `fda`. Naive Bayes and regularised discriminant analysis are defined and not fitted. None of those is a majority baseline.
- Section 2.1 states the class counts. Those counts are not a test-set score, and this proposal does not treat them as one.

## Capabilities

### New Capabilities

- `baselines`: A majority-class null and an unpenalised logistic model reported beside the main model.

### Modified Capabilities

- None. This change is not applied.

## Impact

None in this PR. A later implementation would add two workflows and two columns or rows in the accuracy table.
