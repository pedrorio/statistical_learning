# Spec Delta

## Purpose

Record exact R package versions so `libraries.R` can load the same set on a new machine.

## ADDED Requirements

### Requirement: Locked package versions
`renv.lock` MUST record an exact version for every package named in the data-description, exploratory, outlier, data-reduction, classification, and clustering vectors, and for the packages required to load the report and `test_pipeline`, including `tinytex`. The lockfile MUST be the source of truth for those versions.

#### Scenario: Restore satisfies the loader
- **WHEN** a clean project restores `renv.lock` and sources `libraries.R`
- **THEN** each named package loads and the versions match the lockfile

### Requirement: Tracked activation files
The repository MUST track `renv.lock`, `renv/activate.R`, and `renv/settings.json`. `libraries.R` MUST remain the loader and MUST keep sourcing `./renv/activate.R` before the package lists.

#### Scenario: Activation file is present
- **WHEN** a fresh clone sources `libraries.R`
- **THEN** `./renv/activate.R` exists in the tree and is sourced before `packages/load.R`

### Requirement: Standard renv ignores
Git MUST ignore renv's installed library, local, cellar, lock, python, sandbox, and staging directories. Git MUST NOT ignore the whole `renv` directory or `renv.lock`.

#### Scenario: Library is untracked
- **WHEN** packages are installed into the renv library
- **THEN** that library directory is ignored and `renv.lock` remains a tracked file
