# continuous-integration Specification

## Purpose
Rebuild the knitr report and run the pipeline helper whenever the code changes, and attach the PDF to a release when a version tag is pushed.

## Requirements

### Requirement: Pull request and branch build
On every pull request, and on every push that is not a version tag, GitHub Actions MUST install R 4.6.1, restore `renv.lock`, install TinyTeX, run `make test`, run `make report`, and upload `main.pdf` as a workflow artifact.

#### Scenario: Pull request
- **WHEN** a pull request is opened
- **THEN** the workflow runs `make test` and `make report` and uploads `main.pdf`

### Requirement: Tag release asset
On a push of a tag matching `v*`, a separate job MUST build `main.pdf` the same way and attach that file to the GitHub release for the tag. The workflow MUST NOT create a tag.

#### Scenario: Version tag
- **WHEN** a tag matching `v*` is pushed
- **THEN** `main.pdf` is attached to the GitHub release for that tag and the workflow creates no tag
