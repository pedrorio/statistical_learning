# Design

## Context

See proposal.md. The numbers below are copied from the PDF that is already in the repository (producer pdfTeX, created 7 September 2020). They are not from a re-run. `libraries.R` now sets a seed and the lockfile pins current packages, so `make report` will not reproduce those percentages.

## Goals / Non-Goals

**Goals:**

- One README a reader can follow without opening the PDF first.
- One small PNG taken from the existing report.

**Non-Goals:**

- Publishing a new test accuracy or an interval the report does not contain.
- Editing `main.Rnw`.

## Decisions

- Headline is the maximum cell in Table 3.1: radial SVM on the filtered dataset, 84.95% test accuracy, also stated in section 3.0.3.
- The interval sentence says the report has none, and points at the spec-only `uncertainty` change.
- Figure 2.2 (alcohol by the recoded quality class) is the exported figure because section 2.1 uses it to describe the classes the models predict.

## Risks / Trade-offs

- [Readers may treat 84.95% as the result of `make report`] → The README says the figure comes from the 7 September 2020 report and that a new build is seeded and will differ.

## Migration Plan

None. Documentation only.
