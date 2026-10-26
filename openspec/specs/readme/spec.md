# readme Specification

## Purpose
Tell a reader what the report asks, which file it analyses, what accuracy it published, and which Make targets rebuild it.

## Requirements

### Requirement: Question and data
The README MUST state the classification question. It MUST describe the data using only statements that appear in the report, `bib.bib`, or `data/winequality.txt`, including that the fitted scripts read `data/winequality-red.csv` and do not read the white-wine file.

#### Scenario: Data statement matches the repo
- **WHEN** a reader opens the README
- **THEN** it names `data/winequality-red.csv` and the Cortez et al. 2009 Wine Quality citation used in the report

### Requirement: Headline and figure
The README MUST report the highest test accuracy printed in the existing report and MUST cite the section and table. It MUST state that the report does not publish an interval around that accuracy. It MUST embed one figure exported from that report.

#### Scenario: Published point estimate
- **WHEN** a reader looks for the headline result
- **THEN** the README shows 84.95% for the radial SVM on the filtered dataset, cites Table 3.1 and section 3.0.3, and says no interval is printed

#### Scenario: Exported figure
- **WHEN** a reader views the README
- **THEN** it shows `docs/alcohol-by-quality.png` taken from Figure 2.2 of the existing report

### Requirement: Reproduce
The README MUST document `make deps`, `make test`, and `make report`, and MUST say that these targets replace `knitr.zsh`.

#### Scenario: Build instructions
- **WHEN** a reader follows the README
- **THEN** the three Make targets are the documented way to restore, test, and build the PDF
