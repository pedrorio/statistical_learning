# Spec Delta

## ADDED Requirements

### Requirement: Metrics match hand-computed values
The tests SHALL check balanced accuracy, ROC AUC, and PR AUC against values computed by hand on a small case, and SHALL check that the guess-low PR AUC in the report is the test prevalence, 44/321, and not the 0.569 trapezoid of a constant score.

#### Scenario: Four-row case
- **WHEN** four rows with known probabilities are scored at a fixed cut
- **THEN** balanced accuracy, ROC AUC 3/4, and PR AUC 19/24 match the values worked out in the test comments

### Requirement: The score cut does not see the test rows
The tests SHALL check that score models are selected by the fixed 6.5 cut on models refit inside each fold, that the test cut is chosen from out-of-fold scores, and that perturbing the test rows changes neither the selected candidate nor the cut.

#### Scenario: Test rows are perturbed
- **WHEN** every test predictor and score is replaced
- **THEN** the selected parameters, the out-of-fold scores, and the cut are identical and the test score differs

### Requirement: Paired differences are per split
The tests SHALL check, on the report's own code, that each difference is the model minus the radial SVM with no resampling on the same seed, and that the reported sd is the sample sd.

#### Scenario: Stored rows are reordered
- **WHEN** the stored metric rows are reversed before the report code runs
- **THEN** every paired difference is unchanged

### Requirement: Stored fits reproduce
The tests SHALL refit a fixed sample of the original fits with their stored hyperparameters, without a grid search, and SHALL require the stored test metrics within 1e-9.

#### Scenario: Sampled refit
- **WHEN** five sampled fits, including one SVM and one ROSE fit, are refit
- **THEN** balanced accuracy, ROC AUC, accuracy, the confusion counts, and PR AUC match the stored values

### Requirement: Graded files are only read
The tests SHALL check that `fit.R`, `utils/recipes/step_recipe.R`, `conclusion/`, and `main.pdf` are unchanged since b86768e and that `main.pdf` has md5 2848ef7280e31c430dfd9f3e1fc66ebb.

#### Scenario: Graded check
- **WHEN** the graded test runs
- **THEN** git reports no difference for those paths and the hash matches
