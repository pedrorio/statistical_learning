# Proposal

## Why

A fresh clone cannot rebuild the report. `libraries.R` sources `renv/activate.R`, but that file and `renv.lock` are not in the repository, nothing sets a seed, and no workflow runs `test_pipeline.R` or knits `main.Rnw`.

## What Changes

- Commit `renv.lock`, `renv/activate.R`, `renv/settings.json`, and `.Rprofile`. Pin every package the loader names, plus `tinytex` for the PDF build. `vip` is installed from the CRAN archive because it was removed from CRAN on 2026-07-08.
- Replace the blanket `renv` gitignore rule with renv's standard directory ignores.
- Keep `libraries.R` as the loader. End it with the only `set.seed` call, `set.seed(2020)`.
- Replace undefined `ssource("box_plot.R")` with `source`.
- Call discriminant and naive-Bayes constructors from `parsnip`. They are no longer exported by `discrim` 1.1.0. Engines stay `mda`, `earth`, and `klaR`, and the arguments stay the same. `discrim` 0.1.3 cannot load next to current parsnip because those model names already exist.
- In the winsorise step, replace removed `recipes::terms_select()` with `recipes::recipes_eval_select()` on the same selectors. Winsorise still uses `prob = 0.999`.
- Pass the selection metric by name: `tune::select_best(metric = selection_metric)`. Current tune rejects a positional metric. The chosen metric is still accuracy.
- Pass PCA `options` as a list (`retx`, `scale.`, `center`, all `TRUE`). Current recipes rejects the named logical vector that `c()` produced. The option values are unchanged.
- Add a GitHub Actions workflow that restores the lockfile, runs `make test` and `make report`, uploads `main.pdf`, and, on `v*` tags only, attaches that PDF to the GitHub release. Do not create a tag.

Modelling grids, recipes, the split proportion, and the accuracy metric stay as they are. A new run will not match the September 2020 PDF: that build had no seed and older packages.

## Current code

Before this change the repository does **not** satisfy this proposal.

- No `renv.lock`. `.gitignore` ignores the whole `renv` directory, so `renv/activate.R` is absent. `libraries.R` still tries to source it.
- No `set.seed` anywhere.
- No GitHub Actions workflow. `test_pipeline.R` is not run. `knitr.zsh` builds the PDF only when someone runs it locally.
- `utils/exploratory_data_analysis/data_description/index.R` calls `ssource`, which is not defined, so `libraries.R` stops before the estimation helpers load.
- Model files call `discrim::discrim_linear`, `discrim::discrim_flexible`, `discrim::naive_Bayes`, and `discrim::discrim_regularized`. Those names are not exported from the discrim that current parsnip expects.
- `prep.step_winsorise` calls `recipes::terms_select()`, which current recipes stops on.
- `pipeline()` calls `tune::select_best(selection_metric)` positionally, which current tune rejects.

## Capabilities

### New Capabilities

- `renv-lockfile`: Restore exact package versions for the loader, the report, and `test_pipeline`.
- `project-seed`: One `set.seed(2020)` at the end of `libraries.R`.
- `continuous-integration`: Pull-request and branch builds run the test helper and the report; `v*` tags attach `main.pdf` to the release.

### Modified Capabilities

- `wine-classification-pipeline`: Utility sourcing must finish. The data-description index must source `box_plot.R`.

## Impact

- New: `renv.lock`, `renv/activate.R`, `renv/settings.json`, `.Rprofile`, `.github/workflows/report.yml`.
- Edited: `.gitignore`, `libraries.R`, the winsorise step, four model constructors, `pipeline()`'s `select_best` call, and the box-plot source line.
- No change to grid definitions, recipe step order, split proportion, or the accuracy metric.
