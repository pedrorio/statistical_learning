# Spec Delta

## ADDED Requirements

### Requirement: Tuning selects from the supplied grid on training-split cross-validation
Each fit SHALL tune only over the grid it is given, on cross-validation folds drawn from the outer training split, and SHALL select the grid point with the best mean cross-validated balanced accuracy. No outer test row SHALL be in any analysis or assessment set.

#### Scenario: Two-point grid on 2 by 2 folds (`tests/test_existing_training.R`)
- **WHEN** `fit_job` fits LightGBM with class weights and the fuller XGBoost search without, each on a two-point grid with 2 by 2 folds of a 300-row stratified subset
- **THEN** every fold is built on the training frame, each repeat holds out every training row once, and the selected parameters are the grid point with the highest mean fold balanced accuracy

### Requirement: The test-time cut-off is chosen from out-of-fold predictions without seeing test rows
The cut-off applied to the test predictions SHALL be chosen from the out-of-fold predictions of the selected workflow on the training split. Out-of-fold predictions SHALL exist for every training row in every repeat and SHALL NOT include an outer test row. Changing the test rows SHALL NOT change the selected parameters, the out-of-fold predictions, or the cut-off. For score models, selection SHALL count a prediction of 6.5 or higher as high, on models refit inside each fold.

#### Scenario: Classifier cut from out-of-fold probabilities (`tests/test_existing_training.R`)
- **WHEN** a fit finishes
- **THEN** its saved out-of-fold rows cover each training row twice and no test row, and its cut equals the first-maximum balanced-accuracy cut on those probabilities

#### Scenario: Score model with perturbed test rows (`tests/test_existing_score_cut.R`)
- **WHEN** every test predictor and score is replaced
- **THEN** the selected parameters, the out-of-fold scores, and the cut are unchanged, the out-of-fold scores equal per-fold refits, and the test score changes

#### Scenario: Stored added fits (`tests/test_existing_fit_helpers.R`)
- **WHEN** each of the 35 stored added fits is read
- **THEN** its cut is the one its saved out-of-fold predictions give and its saved test predictions rescore to its stored metrics

### Requirement: Metrics follow their definitions with high as the event
Balanced accuracy, ROC AUC, PR AUC, precision, and recall SHALL treat high as the event. Raw quality scores SHALL be ranked into (0, 1) without changing their order before ROC AUC and PR AUC are computed.

#### Scenario: Four-row case (`tests/test_existing_metrics.R`)
- **WHEN** four rows with known probabilities are scored
- **THEN** balanced accuracy, ROC AUC 3/4, and PR AUC 19/24 match the hand-computed values, and a raw score with the same order gives the same AUCs

### Requirement: Guess-low PR AUC equals the test prevalence
The guess-low baseline SHALL report PR AUC equal to the share of high rows in the test split, 44/321 (0.137) on every stored split, and SHALL NOT report the 0.569 trapezoid of a constant score.

#### Scenario: Report baseline row (`tests/test_existing_paired.R`)
- **WHEN** the report's `load` chunk runs on the stored results
- **THEN** the guess-low row's PR AUC is 44/321

### Requirement: Paired differences are model minus radial SVM on the same split
Each paired difference SHALL be the model and arm's test metric minus that of the radial SVM with no resampling on the same outer seed. The reported standard deviation SHALL be the sample standard deviation of the five differences.

#### Scenario: Stored rows are reordered (`tests/test_existing_paired.R`)
- **WHEN** the stored metric rows are reversed before the report code runs
- **THEN** every difference is unchanged and the table's SD divides by four

### Requirement: Splits, folds, and class weights come from the training split
Each outer split SHALL be a seeded stratified 80/20 split of the 1599 wines into 1278 training and 321 test rows. Folds and inverse-frequency class weights SHALL be computed on the training split only.

#### Scenario: Five stored seeds (`tests/test_existing_fit_helpers.R`)
- **WHEN** the splits for seeds 2021 to 2025 are rebuilt
- **THEN** they are disjoint, cover every row, hold 44 high rows in each test split, match the stored fits' row indices, and give each class half the total training weight

### Requirement: Stored fits are reused only on a matching key and original fits are never rewritten
A stored fit SHALL be reused only when every cache key field matches. A fit for one of the seven original model tags SHALL NOT be created or rewritten.

#### Scenario: Cache and protected paths (`tests/test_existing_fit_helpers.R`)
- **WHEN** a fit is requested with a matching key, a stale key, or an original tag
- **THEN** the matching key returns the stored metrics, the stale key refits, and the original tag is refused when missing and returned unchanged when present

### Requirement: Stored fits reproduce from stored hyperparameters within 1e-9
Refitting a stored original fit from its stored hyperparameters and cut, without a grid search, SHALL reproduce its stored test balanced accuracy, ROC AUC, accuracy, confusion counts, and PR AUC within 1e-9.

#### Scenario: One fit per family (`tests/test_existing_reproduction.R`)
- **WHEN** one sampled fit of each of the seven original families is refit
- **THEN** every stored test metric matches within 1e-9

### Requirement: Graded coursework files do not change
The re-evaluation SHALL NOT change `fit.R`, `utils/recipes/step_recipe.R`, `conclusion/`, or `main.pdf`, whose md5 SHALL stay 2848ef7280e31c430dfd9f3e1fc66ebb.

#### Scenario: Graded check (`tests/test_existing_graded.R`)
- **WHEN** the graded test runs
- **THEN** git reports no difference for those paths against b86768e and the hash matches
