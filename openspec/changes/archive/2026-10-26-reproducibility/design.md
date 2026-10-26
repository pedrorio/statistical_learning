# Design

## Context

See proposal.md. Package names live in character vectors and are loaded with `library(..., character.only = TRUE)`, so a static scan misses them. Snapshot type is `all` so the lockfile records the library after those installs.

## Goals / Non-Goals

**Goals:**

- One lockfile, one seed call, and a workflow that runs `make test` and `make report`.
- Keep the fitted model engines, recipe steps, and accuracy selection rule.

**Non-Goals:**

- A seeded `initial_split` argument, a single `last_fit`, baselines, or interval metrics. Those stay spec-only.
- Matching the September 2020 PDF percentages.

## Decisions

- Install from Posit Package Manager for Ubuntu noble, then snapshot. R is 4.6.1, the same version CI requests.
- `vip` 0.4.6 comes from the CRAN archive URL. The lockfile records that URL.
- Seed `2020` is the course year. It is the last expression in `libraries.R`, so a chunk that sources the loader resets RNG before the next draw. The classification setup chunk sources the loader immediately before the split.
- CI uses `ubuntu-24.04`, `r-lib/actions/setup-r` at 4.6.1, `setup-renv`, and `setup-tinytex`. The tag job is separate and is the only job with `contents: write`. It does not create tags.
- `select_best(metric = ...)`, `parsnip::` constructors, and `recipes_eval_select()` are call-site updates required by the pinned packages. Arguments and engines are unchanged.

## Risks / Trade-offs

- [Full 10×10 grids across five models and three recipes are slow] → The workflow timeout is 360 minutes. The data files are already in the repository, so the job does not skip the fit.
- [A future chunk consumes RNG between the loader and `initial_split`] → The seed still lives in one place. Locking the split itself is the spec-only `locked-test-split` change.
- [Archived `vip` disappears from the archive URL] → The lockfile records the exact tarball URL and can be refreshed later.

## Migration Plan

Install R 4.6.1, run `make deps`, then `make test` and `make report`. Rollback is reverting this change. Model grids are untouched.
