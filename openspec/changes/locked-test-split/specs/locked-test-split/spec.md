# Spec Delta

## Purpose

Draw the test split once, with a fixed seed, and touch it only for the final score after tuning has finished on the training folds.

## ADDED Requirements

### Requirement: Seeded split used once
Classification MUST create exactly one `initial_split` of the recoded red-wine table with a fixed seed, and MUST NOT draw that split again in the same run. The testing portion MUST be passed to evaluation only after hyperparameters are chosen.

#### Scenario: One split
- **WHEN** fits are computed and no saved-fits file is loaded
- **THEN** `initial_split` runs once, with a fixed seed, and its testing rows are not reused to draw another split

### Requirement: Tuning stays on training folds
Hyperparameters MUST be chosen with `vfold_cv` on the training portion only, then `tune_grid` and `select_best` on those folds. The test split MUST NOT be an input to `tune_grid` or `select_best`.

#### Scenario: Selection ignores the test split
- **WHEN** hyperparameters are selected
- **THEN** `select_best` uses the training-fold metric and the test rows are not in the resamples

### Requirement: One final test evaluation
`last_fit` MUST run on the held-out split for the single selected model only. Test metrics MUST NOT be compared across model or recipe candidates.

#### Scenario: Test score is not a selection input
- **WHEN** the report names a preferred model
- **THEN** that choice was made from training-fold metrics, and the test split was scored once
