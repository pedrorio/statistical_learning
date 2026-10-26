# Tasks

## 1. Lockfile and loader

- [x] 1.1 Snapshot `renv.lock` for every package named by the loader vectors and verify `Rscript -e 'source("libraries.R")'` exits 0
- [x] 1.2 Track `renv/activate.R`, `renv/settings.json`, and `.Rprofile`, and ignore only renv's library and cache directories
- [x] 1.3 Source `box_plot.R` with `source` and call `select_best(metric = ...)` so the loader and the pipeline run on the pinned packages

## 2. Seed and CI

- [x] 2.1 Put `set.seed(2020)` once, at the end of `libraries.R`, and verify it is the only `set.seed` in the repository
- [x] 2.2 Add the GitHub Actions workflow that runs `make test` and `make report` on push and pull request, and attaches `main.pdf` on `v*` tags

## Workflow follow-up

- Archive `reproducibility` after the lockfile, seed, and workflow are in place.
