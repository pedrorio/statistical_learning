# Wine classification pipeline

## Purpose

Load the red-wine quality table, recode the score, tune five classifiers on three preprocessing recipes with repeated cross-validation, score the chosen fits on a held-out split, and render that analysis as the knitr report.

## Requirements

### Requirement: Red wine table loading
The loader MUST read one semicolon-separated file with column types `dddddddddddf`, rename columns to syntactic names, and add a `type` factor equal to `red` on every row. Classification and exploratory scripts MUST pass `data/winequality-red.csv`. The white-wine file MUST NOT be read by those scripts.

#### Scenario: Classification load path
- **WHEN** classification builds fits and the saved-fits file is absent
- **THEN** it loads `data/winequality-red.csv` through the recoding loader and does not open `data/winequality-white.csv`

#### Scenario: Constant wine-type column
- **WHEN** a raw file is loaded
- **THEN** every row has `type` equal to the factor level `red`

### Requirement: Quality recoding
The recoding loader MUST replace numeric quality levels 3, 4, 5, and 6 with `low`, and levels 7 and 8 with `high`, and MUST return that factor as `quality`.

#### Scenario: High and low labels
- **WHEN** a row's raw quality is 6 or 7
- **THEN** the recoded `quality` is `low` for 6 and `high` for 7

### Requirement: Filtered dataset recipe
The `fd` recipe MUST be an unprepped `quality ~ .` recipe templated on the training rows, with steps in this order: omit missing numerics, drop zero-variance predictors, ROSE-sample the outcome, drop near-zero-variance predictors, drop numeric predictors correlated above 0.80, drop linear combinations, then winsorise numeric columns.

#### Scenario: Filtered recipe identity
- **WHEN** recipe specs are built for a training frame and outcome `quality`
- **THEN** the first spec has tag `fd`, name `Filtered dataset`, and the step order above

### Requirement: Standardised filtered dataset recipe
The `sfd` recipe MUST apply the same steps as `fd` and then normalise numeric columns. Its tag MUST be `sfd` and its name MUST be `Standardised filtered dataset`.

#### Scenario: Standardised recipe identity
- **WHEN** recipe specs are built
- **THEN** the second spec is `sfd` and ends with numeric normalisation after winsorising

### Requirement: Principal component recipe
The `sfpc` recipe MUST apply the same steps as `fd` and then a principal-component step on numeric columns with variance threshold 0.8 and centering and scaling enabled. It MUST NOT add a separate normalisation step. Its tag MUST be `sfpc`.

#### Scenario: Component recipe identity
- **WHEN** recipe specs are built
- **THEN** the third spec is `sfpc`, named `Standardised filtered principal components`, and its last step is PCA with threshold 0.8

### Requirement: Fitted model set
The computed cross MUST include only `lr`, `svm_poly`, `svm_radial`, `lda`, and `fda`, each paired with `fd`, `sfd`, and `sfpc`. Naive Bayes (`nb`) and regularised discriminant analysis (`rda`) MUST remain defined and MUST NOT be fitted.

#### Scenario: Cross of models and recipes
- **WHEN** fits are computed
- **THEN** the run fits those five tags on the three recipes and does not fit `nb` or `rda`

### Requirement: Logistic regression specification
`lr` MUST be a classification logistic regression on the glmnet engine with tunable penalty and mixture, searched on a regular grid of 5 levels. Its display name MUST be `Logisic regression`.

#### Scenario: Logistic grid
- **WHEN** the logistic model spec is built
- **THEN** the tag is `lr` and the grid varies penalty and mixture at 5 levels

### Requirement: Polynomial SVM specification
`svm_poly` MUST be a classification polynomial SVM on the kernlab engine with tunable degree, scale factor, and cost, searched on a regular grid of 3 levels.

#### Scenario: Polynomial SVM grid
- **WHEN** the polynomial SVM spec is built
- **THEN** the tag is `svm_poly` and the grid varies degree, scale factor, and cost at 3 levels

### Requirement: Radial SVM specification
`svm_radial` MUST be a classification radial SVM on the kernlab engine with tunable RBF sigma and cost, searched on a regular grid of 5 levels.

#### Scenario: Radial SVM grid
- **WHEN** the radial SVM spec is built
- **THEN** the tag is `svm_radial` and the grid varies RBF sigma and cost at 5 levels

### Requirement: Linear discriminant specification
`lda` MUST be a classification linear discriminant model on the mda engine with a tunable penalty, searched on a regular grid of 5 levels.

#### Scenario: LDA grid
- **WHEN** the linear discriminant spec is built
- **THEN** the tag is `lda` and the grid varies penalty at 5 levels

### Requirement: Flexible discriminant specification
`fda` MUST be a classification flexible discriminant model on the earth engine with tunable number of terms and product degree, searched with grid size 5.

#### Scenario: FDA grid
- **WHEN** the flexible discriminant spec is built
- **THEN** the tag is `fda` and the grid size is the integer 5

### Requirement: Training split and fold resampling
When fits are computed, the pipeline MUST split the recoded table with `initial_split` at proportion 0.8, with no seed and no stratification argument. It MUST build folds only on the training portion, with 10 folds, 10 repeats, and stratification on `quality`. The testing portion MUST NOT be passed to `vfold_cv`.

#### Scenario: Unseeded stratified folds on training rows
- **WHEN** the saved-fits file is absent and classification creates the split
- **THEN** the split uses proportion 0.8 with no seed, and the fold object is `vfold_cv` of the training data only (`v = 10`, `repeats = 10`, `strata = quality`)

### Requirement: Accuracy selection and held-out score
Each model-recipe pair MUST be tuned with `tune_grid` using a metric set that contains only accuracy, grid control that saves predictions, and `select_best` on the metric name `accuracy`. The selected workflow MUST be scored with `last_fit` on the original split. Displayed accuracy MUST be the first test-metric row's `.estimate`. The comparison table MUST format those test estimates as percentages rounded to four decimal places before scaling.

#### Scenario: Selection uses training resamples
- **WHEN** a workflow is tuned
- **THEN** `select_best` chooses the grid point by accuracy on the training folds, and the test split is used only by the subsequent `last_fit`

#### Scenario: Report prints one test estimate
- **WHEN** the report prints a model-recipe accuracy
- **THEN** the value is that fit's first test `.estimate`, rendered as a percentage

### Requirement: Saved fits short-circuit
Classification MUST read `results/classification_and_discrimination_fits.Rda` when that file exists and MUST NOT recompute the split or the grid in that case. When the file is absent it MUST compute the fits and save them to that path with `saveRDS`.

#### Scenario: Existing fits file
- **WHEN** the fits file exists before the classification chunk runs
- **THEN** `fits` is loaded from that file and `initial_split` is not called

#### Scenario: Missing fits file
- **WHEN** the fits file does not exist
- **THEN** the pipeline computes every active model-recipe fit and writes the RDS file

### Requirement: Report document
`main.Rnw` MUST be the knitr root. It MUST include the introduction, exploratory data analysis, classification, and conclusion children, then the `bib.bib` bibliography in `unsrt` style, a list of figures, and a list of tables. The build script MUST knit `main.Rnw` to `main.tex` with `knit2pdf`, run `lualatex`, `pdflatex`, `bibtex` twice, and `pdflatex` twice, then delete bibliography and LaTeX intermediate files while leaving `main.pdf`.

#### Scenario: Knitr build command
- **WHEN** `knitr.zsh` runs
- **THEN** it executes that knit and LaTeX sequence and removes `*.aux`, `*.toc`, `*.log`, `*.out`, `*.tex`, and bibliography intermediates

### Requirement: Library entry point
`libraries.R` MUST source `./renv/activate.R`, then `packages/load.R`, then `utils/index.R`. Package loading MUST `library()` every package named in the data-description, exploratory, outlier, data-reduction, classification, and clustering vectors in `packages/helpers/list.R`.

#### Scenario: Sourcing the loader
- **WHEN** a report chunk sources `libraries.R`
- **THEN** activation, package loading, and utility sourcing run in that order

### Requirement: Pipeline re-entry helper
`test_pipeline` MUST call `pipeline` again with the stored model config, stored recipe config, and the metrics, selection metric, folds, training data, and split passed by the caller. Sourcing the helper file MUST NOT itself fit a model.

#### Scenario: Helper delegates to the pipeline
- **WHEN** `test_pipeline` is called with a previous fit and the original resampling objects
- **THEN** it returns the result of `pipeline` for that fit's model and recipe configs
