# Spec Delta

## ADDED Requirements

### Requirement: A failed or unsupported fit is recorded and the run continues
A fit whose engine ignores class weights SHALL be recorded as one row with status `unsupported`. A fit that throws SHALL be recorded as one row with status `na`, NA metrics, and the error message as its detail. Neither SHALL stop the other jobs in the run.

#### Scenario: Unsupported weight arm (`tests/test_failed_fit_recording.R`)
- **WHEN** a weight arm is fit for an engine marked as ignoring class weights
- **THEN** `fit_job` returns and saves one row with status `unsupported` and the model's tag and name

#### Scenario: One job throws in a 2 by 2 run (`tests/test_failed_fit_training.R`)
- **WHEN** two jobs run through `fit_job` as `fit_reevaluation` runs them and one has a grid its model cannot tune
- **THEN** the run returns two rows, the good job is `ok`, and the failing job is `na` with its error as the detail

### Requirement: The stored refit summary records guess-low PR AUC as the test prevalence
The refit summary SHALL store the guess-low PR AUC of each split as the share of high rows in its test split, and SHALL NOT store the PR AUC of a constant score.

#### Scenario: Stored summary (`tests/test_guess_low_stored_pr_auc.R`)
- **WHEN** `run_pr_original.rds` is read
- **THEN** its five guess-low PR AUC values are 44/321
