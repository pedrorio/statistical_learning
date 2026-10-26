# Design

## Context

See proposal.md. Spec only. Do not implement in this PR.

## Goals / Non-Goals

**Goals:**

- Record that the published number is a single test `.estimate` and that fold summaries already exist unused on `train$metrics`.

**Non-Goals:**

- Computing a bootstrap interval or a per-class table in this PR.
- Inventing an interval for the September 2020 percentages. The README states that none was published.

## Decisions

- Accept either the resample mean ± standard deviation or a bootstrap confidence interval. The current code has the columns for the first and prints neither.
- The required slice is quality class, because that is the outcome the report recodes and then models.

## Risks / Trade-offs

- [Printing fold standard deviation of training accuracy is not a confidence interval on the test score] → The requirement allows either that spread or a bootstrap interval on the reported score. The choice is left to the implementing change.

## Migration Plan

None until a later change applies this proposal.
