# Design

## Context

See proposal.md. Spec only. Do not implement in this PR.

## Goals / Non-Goals

**Goals:**

- State the two baselines and record that the current catalogue does not contain them.

**Non-Goals:**

- Fitting a null model or an unpenalised logistic regression in this PR.
- Changing the radial SVM, the recipes, or the 2020 table.

## Decisions

- The null baseline is a majority-class classifier because the outcome is a two-level factor, not a numeric mean.
- The linear baseline is an unpenalised logistic regression, because the current `lr` model already tunes a penalty and is not that baseline.

## Risks / Trade-offs

- [A majority baseline on this table can exceed a tuned model's test accuracy] → That is the point of reporting it. Section 2.1 already says the low class dominates. The comparison belongs on the same test split, which this PR does not compute.

## Migration Plan

None until a later change applies this proposal.
