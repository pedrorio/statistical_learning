# Spec Delta

## Purpose

Extend the red-wine re-evaluation with saved probabilities, precision metrics, LightGBM, a larger XGBoost search, and models of the raw quality score, without changing the graded report or the existing grids.

## ADDED Requirements

### Requirement: New fits save their predictions
Each fit this change runs SHALL save the out-of-fold predictions used to choose the cut-off and the test-set predictions used to score that fit. A classifier saves class probabilities. A score model saves the predicted quality score. The existing 105 fits SHALL NOT be rerun through the 10 by 10. Test probabilities for those fits MAY be obtained by one refit of the already selected workflow, written to new files, and kept only when that refit reproduces the stored test metrics.

#### Scenario: A finished summary has both prediction sets
- **WHEN** a new fit has completed
- **THEN** its summary file contains the out-of-fold predictions and the test predictions

### Requirement: High-class precision metrics are reported
Each new fit SHALL report PR AUC, precision for high, and recall for high at the chosen cut-off, together with balanced accuracy, ROC AUC, and plain accuracy. High quality is the event.

#### Scenario: The positive class is scored at the chosen cut
- **WHEN** a fit has a chosen cut-off and a scored test set
- **THEN** precision and recall count high as the positive class, and PR AUC uses the saved ranking

### Requirement: LightGBM is searched with and without class weights
LightGBM SHALL be a `boost_tree` model on the lightgbm engine, with one thread, tuned over trees, learn_rate, num_leaves, min_n, and the feature fraction, on 40 space-filling candidates. Early stopping SHALL use a hold-out taken from the analysis set of the resample. The model SHALL be fit with training-split class weights and without them. Selection SHALL be 10 by 10 balanced accuracy on the training split.

#### Scenario: Early stopping does not see the test set
- **WHEN** a LightGBM resample is fit
- **THEN** the early-stopping hold-out is drawn from that resample's analysis set, and the outer test split is not read

### Requirement: A fuller XGBoost search sits beside the light arm
A second XGBoost search SHALL tune tree_depth, learn_rate, min_n, mtry, loss_reduction, and sample_size on 40 space-filling candidates, with trees fixed at 500, with class weights and without them. The existing nine-point XGBoost arm SHALL stay as it is, including its ROSE cell.

#### Scenario: The light arm is still the nine-point grid
- **WHEN** the existing XGBoost arm is fit
- **THEN** it still uses the nine-point tree_depth by learn_rate grid and trees fixed at 500

### Requirement: Score models rank the raw quality score
Random forest, LightGBM, and penalised linear regression SHALL be fit to the integer quality score. Inside the 10 by 10, a prediction of 6.5 or higher SHALL count as high. After the candidate is selected, the cut on the predicted score SHALL be chosen from out-of-fold scores and applied once to the test scores. The random forest SHALL keep the existing nine-point grid. The linear model SHALL keep the existing penalty by mixture grid. Score LightGBM SHALL use the 40-candidate search.

#### Scenario: The test set is scored once
- **WHEN** a score model is evaluated
- **THEN** the test scores are predicted once, after the cut has been chosen on out-of-fold scores

### Requirement: Original fits gain test PR AUC from one refit
Each of the 105 existing fits SHALL be refit once from its stored hyperparameters and cut-off, on that seed's outer training split. The 10 by 10 SHALL NOT be rerun. Test probabilities and PR AUC SHALL be written to new files, and the existing per-fit files SHALL stay unchanged.

#### Scenario: A reproduced workflow supplies PR AUC
- **WHEN** the one-shot refit matches the stored ROC AUC, balanced accuracy, accuracy, and confusion counts within 1e-9
- **THEN** PR AUC is computed from that refit's test probabilities

#### Scenario: A mismatch is retried on the original stream
- **WHEN** the first refit does not match the stored test metrics
- **THEN** it is retried once on the original L'Ecuyer stream

#### Scenario: A workflow that does not reproduce is not given a score
- **WHEN** the refit does not match on either attempt
- **THEN** its PR AUC is not reproducible and the existing per-fit file is unchanged

### Requirement: Paired split differences are reported
For every fitted model and arm, the report SHALL list the five per-split differences from the radial SVM with no resampling, for balanced accuracy, ROC AUC, and PR AUC, with the mean and standard deviation of each set. The report SHALL state that the score cut of 6.5 is the fixed definition of high for qualities 7 and 8 and was not tuned, and that each cross-validation fold refits the score model before that cut is applied.

#### Scenario: The report compares each arm on the same splits
- **WHEN** the report is built from the saved per-seed metrics
- **THEN** every model and arm has five paired differences, their mean, and their sd on balanced accuracy, ROC AUC, and PR AUC

### Requirement: The existing protocol and graded files stay
The five seeds 2021–2025, the stratified 80/20 splits, the training-only 10 by 10, balanced-accuracy selection, and one test score SHALL stay. Existing grids, including both SVMs, SHALL stay. This change SHALL NOT edit `main.pdf`, the graded conclusion, `fit.R`, or `utils/recipes/step_recipe.R`.

#### Scenario: Graded artifacts are untouched
- **WHEN** this change has been implemented
- **THEN** the committed `main.pdf` hash is unchanged and `fit.R` and `utils/recipes/step_recipe.R` have no edits
