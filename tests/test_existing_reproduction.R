# Refit one stored fit per model family of the 105 original fits, from its
# stored hyperparameters (no grid search) through the repo's refit path, and
# check the stored test metrics come back within 1e-9.
source("reevaluation/refit_pr_auc.R")
Sys.setenv(OMP_NUM_THREADS = "1")
started <- proc.time()[["elapsed"]]

stored <- readRDS("results/reevaluation/metrics.rds")
pr <- readRDS("results/reevaluation/metrics_pr_original.rds")
families <- sort(unique(stored$model))
stopifnot(nrow(stored) == 105)
stopifnot(identical(families, sort(c("fda", "lda", "lr", "rf", "svm_poly", "svm_radial", "xgb"))))

# One fit per family, drawn with a fixed seed.
picked <- withr::with_seed(20261027, vapply(families, function(family) {
  rows <- which(stored$model == family)
  rows[[sample.int(length(rows), 1)]]
}, integer(1)))

loaded <- load_recode_and_score()
outers <- make_outer_splits(loaded$data, loaded$score, original_seeds, 10, 10)
base_stream <- get(".Random.seed", envir = .GlobalEnv)
outer_by_seed <- stats::setNames(outers, as.character(original_seeds))
models <- reevaluation_models()

for (i in picked) {
  row <- stored[i, ]
  pr_row <- pr[pr$model == row$model & pr$arm == row$arm & pr$seed == row$seed, ]
  mode <- if (identical(pr_row$pass, "first")) "first" else "lecuyer"
  t0 <- proc.time()[["elapsed"]]
  refit <- suppressWarnings(fit_stored_workflow(
    row, outer_by_seed[[as.character(row$seed)]], models[[row$model]], mode, base_stream
  ))
  check <- comparison(refit$scored, row)
  pr_diff <- abs(refit$scored$pr_auc - pr_row$pr_auc)
  message(sprintf(
    "%-10s %s__%s__%d (%s): max abs diff %.3g, PR AUC diff %.3g, %.2f s",
    row$model, row$model, row$arm, row$seed, mode, check$max_abs, pr_diff,
    proc.time()[["elapsed"]] - t0
  ))
  stopifnot(check$within, pr_diff <= 1e-9)
}

message(sprintf("existing reproduction: ok (%.1f s)", proc.time()[["elapsed"]] - started))
