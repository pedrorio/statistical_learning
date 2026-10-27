# Spec Delta

## Purpose

A separate re-evaluation of the red-wine classifiers selects on balanced accuracy, learns winsorise statistics from the training predictors only, and reports whether each model beats a guess-low baseline under ROSE, class weights, or no resampling.

## ADDED Requirements

### Requirement: The re-evaluation is separate from the graded report
The change SHALL add a labelled re-evaluation and SHALL NOT modify the committed `main.pdf`, `conclusion/conclusion.Rnw`, `fit.R`, `utils/estimation/pipeline.R`, or `utils/recipes/step_recipe.R`. The original fit SHALL keep an unstratified 80% split and accuracy as its selection metric.

#### Scenario: Graded path is untouched
- **WHEN** the original fit entry point and the winsorise step are read after this change
- **THEN** `fit.R` still selects on accuracy with an unstratified split, and `utils/recipes/step_recipe.R` is byte-for-byte unchanged

### Requirement: Selection uses balanced accuracy
The re-evaluation SHALL select each grid point by mean cross-validated balanced accuracy with high quality as the event. It SHALL report test ROC AUC and SHALL NOT use ROC AUC, test balanced accuracy, or test accuracy to choose a grid point, a threshold, or which rows to show.

#### Scenario: Grid selection stays on the training folds
- **WHEN** a model grid is tuned
- **THEN** the selected parameters are the ones with the best mean training-fold balanced accuracy, and no test row is an input to that choice

### Requirement: Every arm reports the same scores and the guess-low baseline
For every model and resampling arm, the report SHALL include test confusion counts with high as the positive class, balanced accuracy, and ROC AUC. The same outer splits SHALL include a guess-low baseline that predicts low for every test row, with balanced accuracy 0.5 and ROC AUC 0.5.

#### Scenario: Baseline row is present
- **WHEN** the balanced-accuracy table is built
- **THEN** it has one guess-low row and one row for each of the seven models on each of the three arms, and each row has confusion counts, balanced accuracy, and ROC AUC

### Requirement: A reported win clears every outer split
The report SHALL describe a model and arm as beating the baseline only when all five test balanced accuracies are greater than 0.5. A fit that produces no predictions SHALL be stored as `NA` and SHALL NOT be described as a win. The report SHALL still show the mean, standard deviation, and minimum.

#### Scenario: One split fails
- **WHEN** four test balanced accuracies are above 0.5 and one is not, or one is `NA`
- **THEN** that model and arm is not described as beating the baseline

### Requirement: Winsorise statistics come from the training predictors
The re-evaluation winsorise step SHALL estimate the median, the MAD, and the Huber correlation on the training predictors only, pooled across classes, and bake SHALL apply those stored values. Bake SHALL NOT read the outcome and SHALL NOT recompute them. The graded data.frame call drops `prob = 0.999` into `as.matrix`, so the stored correlation SHALL use const 2 and the matrix default probability 0.95.

#### Scenario: Training rows match the graded call
- **WHEN** the step is prepared on a training frame and baked on that frame
- **THEN** the predictors match `robustHD::winsorize` on those training predictors

#### Scenario: Labels do not affect the transform
- **WHEN** a prepared re-evaluation recipe bakes the same predictors twice, once with the outcome removed or permuted
- **THEN** the predictor values are identical

### Requirement: Outer splits are seeded and stratified
Each outer split SHALL set `RNGkind("L'Ecuyer-CMRG")` and `set.seed` to one of 2021, 2022, 2023, 2024, and 2025, then take an 80/20 `initial_split` stratified on quality. Hyperparameters SHALL be chosen only by 10 by 10 cross-validation stratified on quality on that training split.

#### Scenario: Five fixed seeds
- **WHEN** the re-evaluation fit starts
- **THEN** it uses exactly the seeds 2021 through 2025 and a stratified 80/20 split on each

### Requirement: The threshold uses training folds only
The threshold SHALL be chosen from out-of-fold predictions of the already selected workflow on the training folds, over 0.01, 0.02, ..., 0.99, to maximise balanced accuracy. The grid search SHALL use `save_pred = FALSE`. The driver SHALL NOT call `pipeline()`.

#### Scenario: Threshold search inputs
- **WHEN** the threshold is chosen
- **THEN** every prediction in that search is an out-of-fold prediction from the training split

### Requirement: Each test split is predicted once
After the threshold is fixed, the test split SHALL be predicted once. The report SHALL show the mean, standard deviation, and minimum of test balanced accuracy across the five seeds for every model and arm.

#### Scenario: No second test score
- **WHEN** a test split has been scored
- **THEN** that split is not predicted again to choose a model, a grid point, or a threshold

#### Scenario: Spread is reported
- **WHEN** the report is rendered
- **THEN** it shows the mean, standard deviation, and minimum of test balanced accuracy across the five seeds

### Requirement: The three resampling arms share one filtered recipe
The comparison SHALL use the filtered predictor steps only, with no standardisation and no PCA, crossed with ROSE, class weights, and neither. No arm SHALL apply ROSE together with class weights. ROSE SHALL be `themis::step_rose` on the outcomes.

#### Scenario: ROSE excludes weights
- **WHEN** the ROSE arm is built
- **THEN** the recipe calls `themis::step_rose` and the model is given neither case weights nor `class.weights`

### Requirement: Class weights come from the training split
Case weights for glmnet, ranger, xgboost, mda LDA, and earth FDA SHALL be inverse-frequency weights `n / (2 * n_c)` from the outer training split. The two kernlab SVMs SHALL receive a named `class.weights` vector from that same split. If that argument does not change the fitted SVM, the weight cell SHALL be `unsupported` and SHALL NOT be replaced by an unweighted score.

#### Scenario: Weights exclude the test split
- **WHEN** the weight arm is built
- **THEN** the recipe does not call `step_rose`, and the weights are computed from the training split only

### Requirement: Class-weighted SVM probabilities follow the high class
A kernlab SVM fit with class weights SHALL report a high-class probability that rises with the high class. Kernlab relevels the outcome with `as.factor` inside its class-weighted probability model, and that sorts `low` and `high` the wrong way, so those two columns are swapped relative to the decision value. The re-evaluation SHALL correct that mapping where the probability is produced.

#### Scenario: Separable weighted SVM
- **WHEN** a class-weighted SVM is fit on easily separable low and high data
- **THEN** the AUC of the high-class probability is above 0.5 and that probability is higher on high rows than on low rows

### Requirement: The model list adds ranger and xgboost
The model list SHALL be logistic regression, polynomial SVM, radial SVM, LDA, FDA, a ranger random forest, and an xgboost boosted tree. The five existing grids and the 10 by 10 cross-validation SHALL remain those already used on this branch.

#### Scenario: Old grids are not replaced
- **WHEN** the five existing models are fit in the re-evaluation
- **THEN** each uses the same grid it uses in the original fit on this branch

### Requirement: The new models have their own small grids
The random forest SHALL tune `mtry` and `min_n` with a regular grid of 3 levels, SHALL fix `trees` at 500, and SHALL set `num.threads` to 1. The boosted tree SHALL tune `tree_depth` and `learn_rate` with a regular grid of 3 levels, SHALL fix `trees` at 500 and `min_n` at 10, and SHALL set `nthread` to 1.

#### Scenario: Fit manifest
- **WHEN** the re-evaluation fit has completed
- **THEN** the manifest lists 7 models, 3 arms, and 5 outer seeds

### Requirement: Summaries stay off the graded cache
The fitter SHALL write one tibble summary per model, arm, and outer seed under `results/reevaluation/`, with test metrics, confusion counts, chosen parameters, and the chosen threshold. Summaries SHALL NOT contain ggplot objects. The fitter SHALL NOT create or delete files under `results/fits/` and SHALL NOT render `build/main.pdf`.

#### Scenario: Original cache files
- **WHEN** the re-evaluation fitter runs
- **THEN** it does not write under `results/fits/` and it does not render `build/main.pdf`

### Requirement: The write-up is labelled as a re-evaluation
The write-up SHALL be `reevaluation/report.Rnw`, rendered to `build/reevaluation.pdf`. Its opening paragraph SHALL say that it is not the graded conclusion and that its numbers are not Table 3.1. This change SHALL NOT edit `README.md`. The committed `main.pdf` hash SHALL stay unchanged.

#### Scenario: Report identity
- **WHEN** `build/reevaluation.pdf` is built
- **THEN** the committed `main.pdf` hash is unchanged and the new PDF's source is `reevaluation/report.Rnw`

### Requirement: Parallel fits do not reseed the workers
Workers SHALL NOT call `set.seed` or `RNGkind`. Parallelism SHALL be `mclapply` with `mc.set.seed` enabled. Adding ranger and xgboost SHALL NOT change the version of any package already recorded in `renv.lock`.

#### Scenario: Lockfile pin
- **WHEN** `renv.lock` changes to add the new models
- **THEN** every package that was already recorded keeps its version
