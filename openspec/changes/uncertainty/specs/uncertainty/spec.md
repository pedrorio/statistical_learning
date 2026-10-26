# Spec Delta

## Purpose

Publish a spread with each accuracy, and a metric on each quality class, instead of one test-set percentage.

## ADDED Requirements

### Requirement: Interval beside the point estimate
Every accuracy the report prints MUST include a spread: the mean and standard deviation across resampling folds, or a bootstrap confidence interval. A single test `.estimate` MUST NOT be the only number shown.

#### Scenario: Spread is printed
- **WHEN** the report states a model accuracy
- **THEN** the same statement includes either the fold mean and standard deviation or a bootstrap confidence interval

### Requirement: Slice metrics
The report MUST show a classification metric on each level of `quality` (`low` and `high`).

#### Scenario: Both classes are scored
- **WHEN** the comparison of models is rendered
- **THEN** it includes a metric for the low class and a metric for the high class, not only overall accuracy
