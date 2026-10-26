# Spec Delta

## Purpose

Show a majority-class null and an unpenalised logistic model on the same held-out split as the main classifier.

## ADDED Requirements

### Requirement: Null baseline
The report MUST score a majority-class classifier on the same held-out split as the main model and MUST show that score beside the main model.

#### Scenario: Majority score is shown
- **WHEN** the accuracy comparison is rendered
- **THEN** it includes the majority-class accuracy on the test split next to the main model

### Requirement: Plain logistic baseline
The report MUST score an unpenalised logistic classifier, with no tuned penalty, on that same split and MUST show it beside the main model.

#### Scenario: Unpenalised logistic score is shown
- **WHEN** the accuracy comparison is rendered
- **THEN** it includes an unpenalised logistic accuracy next to the main model, distinct from the tuned elastic-net logistic
