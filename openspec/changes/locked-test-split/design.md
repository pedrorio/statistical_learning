# Design

## Context

See proposal.md. Spec only. Do not implement in this PR.

## Goals / Non-Goals

**Goals:**

- Record the target split protocol and the places the test set already leaks into model choice.

**Non-Goals:**

- Editing `initial_split`, `pipeline()`, or the Rnw in this PR.

## Decisions

- Keep the requirement as a future contract. The training-fold half is already true and the proposal says so. The single-test-evaluation half is not.

## Risks / Trade-offs

- [Implementing this later changes the published ranking] → That is why it stays spec-only. The September 2020 table compared 15 test scores.

## Migration Plan

None until a later change applies this proposal.
