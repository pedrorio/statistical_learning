# Spec Delta

## MODIFIED Requirements

### Requirement: Library entry point
`libraries.R` MUST source `./renv/activate.R`, then `packages/load.R`, then `utils/index.R`. Package loading MUST `library()` every package named in the data-description, exploratory, outlier, data-reduction, classification, and clustering vectors in `packages/helpers/list.R`. The data-description index MUST source `box_plot.R` with `source`. Sourcing `libraries.R` from the repository root MUST return without an undefined-function error.

#### Scenario: Sourcing the loader
- **WHEN** a report chunk sources `libraries.R` from the repository root
- **THEN** activation, package loading, and utility sourcing run in that order and the box-plot helper is defined
