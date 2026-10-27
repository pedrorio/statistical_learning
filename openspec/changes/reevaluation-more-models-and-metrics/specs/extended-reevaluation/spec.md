# Spec Delta

## Purpose

Extend the red-wine re-evaluation with saved probabilities, precision metrics, LightGBM, a larger XGBoost search, and models of the raw quality score, without changing the graded report or the existing grids.

## ADDED Requirements

### Requirement: New fits save their predictions
Each fit this change runs SHALL save the out-of-fold predictions used to choose the cut-off and the test-set predictions used to score that fit. A classifier saves class probabilities. A score model saves the predicted quality score. The existing 105 fits SHALL NOT be rerun to backfill predictions.

#### Scenario: A finished summary has both prediction sets
- **WHEN** a new fit has completed
- **THEN** its summary file contains the out-of-fold predictions and the test predictions

### Requirement: High-class precision metrics are reported
Each new fit SHALL report average precision, precision for high, and recall for high at the chosen cut-off, together with balanced accuracy, ROC AUC, and plain accuracy. High quality is the event.

#### Scenario: The positive class is scored at the chosen cut
- **WHEN** a fit has a chosen cut-off and a scored test set
- **THEN** precision and recall count high as the positive class, and average precision uses the saved ranking

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

### Requirement: The existing protocol and graded files stay
The five seeds 2021–2025, the stratified 80/20 splits, the training-only 10 by 10, balanced-accuracy selection, and one test score SHALL stay. Existing grids, including both SVMs, SHALL stay. This change SHALL NOT edit `main.pdf`, the graded conclusion, `fit.R`, or `utils/recipes/step_recipe.R`.

#### Scenario: Graded artifacts are untouched
- **WHEN** this change has been implemented
- **THEN** the committed `main.pdf` hash is unchanged and `fit.R` and `utils/recipes/step_recipe.R` have no edits
