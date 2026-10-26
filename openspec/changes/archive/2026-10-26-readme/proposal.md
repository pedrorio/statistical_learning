# Proposal

## Why

The README is a course link and a grade. It does not say what question the report answers, where the data come from, what the report found, or how to rebuild it.

## What Changes

- State the classification question in the words the report uses.
- Describe the data only from `main` report text, `bib.bib`, and `data/winequality.txt`.
- Report the highest test accuracy printed in the existing report, cite the section and table, and say that the report does not publish an interval around that number.
- Commit one figure cropped from that report under `docs/`.
- Document `make deps`, `make test`, and `make report`, and say they replace `knitr.zsh`.
- Do not invent a metric. Do not change the model code in this change.

## Current code

Before this change the repository does **not** satisfy this proposal. `README.md` links to IST, MECD, and the course, then records the project grade 18.0/20.0. It has no question, no data description, no accuracy, no figure, and no build instructions.

The September 2020 report does **not** satisfy the interval part of the headline. Table 3.1 and section 3.0.3 print a single test-set percentage per model. They do not print a fold standard deviation or a confidence interval. This change records that fact. It does not compute a new interval.

## Capabilities

### New Capabilities

- `readme`: The project front page states the question, the data, the published headline, and the Make workflow.

### Modified Capabilities

- None.

## Impact

- Rewritten `README.md`.
- New `docs/alcohol-by-quality.png`, cropped from Figure 2.2 of the existing `main.pdf`.
