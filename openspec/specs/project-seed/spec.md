# project-seed Specification

## Purpose
Give every entry point the same random-number seed without scattering `set.seed` calls.

## Requirements

### Requirement: Single project seed
The repository MUST contain exactly one `set.seed` call. That call MUST be the last expression in `libraries.R` and MUST use the value `2020`.

#### Scenario: One seed call
- **WHEN** the R sources are searched for `set.seed`
- **THEN** the only match is `set.seed(2020)` at the end of `libraries.R`
