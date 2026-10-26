# Statistical Learning — wine quality classification

Course project (Instituto Superior Técnico, MECD, Statistical Learning 2019/2020) that classifies Portuguese Vinho Verde red wines as high or low quality from physicochemical measurements.

## Question

Can physicochemical measurements separate high-quality red wines from low-quality ones, and which of the fitted classifiers has the highest held-out accuracy?

## Stack

- R, sourced from `libraries.R` (no `DESCRIPTION`, no lockfile in the repository today).
- tidymodels-style fitting: `recipes`, `parsnip`, `workflows`, `rsample`, `tune`, `yardstick`, `dials`, `discrim`, `themis`, plus the engines those models declare (`glmnet`, `kernlab`, `mda`, `earth`).
- Report: knitr child documents rooted at `main.Rnw`, bibliography `bib.bib`, built by `knitr.zsh`. `main.pdf` is committed.
- Helper entry point: `utils/estimation/test_pipeline.R` defines `test_pipeline()` and does not assert anything.

## Data

- `data/winequality-red.csv` and `data/winequality-white.csv` are in the repository, with `data/winequality.txt` (UCI Wine Quality citation text).
- Every analysis script loads only the red file. The white file is not read.
- Citation in the report and `bib.bib`: Cortez et al., Wine Quality, UCI / Decision Support Systems 2009.

## Current pipeline (do not change modelling behaviour)

1. `load_raw_data` reads a semicolon-separated file (`col_types` `dddddddddddf`), syntactic names, and adds a constant `type` factor `"red"`.
2. `load_recoded_data` recodes `quality` 3–6 to `low` and 7–8 to `high`.
3. When `results/classification_and_discrimination_fits.Rda` is absent, classification draws an 80/20 `initial_split` with no seed and no strata, then `vfold_cv` on the training rows only (`v = 10`, `repeats = 10`, `strata = quality`).
4. Three unprepped recipes (`fd`, `sfd`, `sfpc`) are crossed with five active models (`lr`, `svm_poly`, `svm_radial`, `lda`, `fda`). Naive Bayes and regularised discriminant analysis are defined and not fitted.
5. `tune::tune_grid` selects hyperparameters by accuracy on the training folds. `tune::last_fit` scores the selected workflow once on the split. The report prints that single test `.estimate`.
6. Fits are saved with `saveRDS` and reused on the next knit.

## Build

`knitr.zsh` runs `knitr::knit2pdf('main.Rnw', 'main.tex')`, then `lualatex`, `pdflatex`, `bibtex` twice, `pdflatex` twice, deletes LaTeX intermediates, and calls `open main.pdf`.

## Constraints for later changes

Modelling code, recipes, the split, the metric, and the reported numbers stay as they are unless a change proposal says otherwise. Tooling (lockfile, ignore rules, Makefile, CI, README) must not alter those results.
