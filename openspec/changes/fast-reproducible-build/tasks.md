# Tasks

## 1. Fit summaries

- [ ] 1.1 Add `fit.R` and per-combination `.rds` summaries, and point the classification chunk at them. Verify a missing manifest stops the knit with the fit command in the message.
- [ ] 1.2 Seed L'Ecuyer-CMRG once and fit combinations with `parallel::mclapply`. Verify a second run logs each combination as cached.

## 2. Fresh clone and render

- [ ] 2.1 Commit `renv.lock` and renv activation, drop unused packages, fix `ssource` and `terms_select`, and create `results/` at runtime. Verify `Rscript tests/test_winsorise.R` passes.
- [ ] 2.2 Load packages from the `main.Rnw` setup chunk, use one figure device, and render with `knitr::knit` plus one `latexmk -pdf` into `build/`. Verify the committed `main.pdf` hash is unchanged.
