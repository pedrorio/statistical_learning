# Refit a fixed sample of the 105 original fits with their stored
# hyperparameters (no grid search) through the repo's refit path, and check the
# stored test metrics come back within 1e-9.
source("reevaluation/refit_pr_auc.R")
Sys.setenv(OMP_NUM_THREADS = "1")
started <- proc.time()[["elapsed"]]

stored <- readRDS("results/reevaluation/metrics.rds")
pr <- readRDS("results/reevaluation/metrics_pr_original.rds")
stopifnot(nrow(stored) == 105)

# Three cheap fits, one SVM, and one ROSE fit (whose recipe draw needs the
# original L'Ecuyer stream), drawn with a fixed seed.
cheap <- which(stored$model %in% c("lr", "lda", "fda", "xgb") & stored$arm != "rose")
svm <- which(stored$model %in% svm_tags)
rose <- which(stored$model %in% c("lr", "lda", "fda", "xgb") & stored$arm == "rose")
picked <- withr::with_seed(20261027, c(sample(cheap, 3), sample(svm, 1), sample(rose, 1)))

loaded <- load_recode_and_score()
outers <- make_outer_splits(loaded$data, loaded$score, original_seeds, 10, 10)
base_stream <- get(".Random.seed", envir = .GlobalEnv)
outer_by_seed <- stats::setNames(outers, as.character(original_seeds))
models <- reevaluation_models()

for (i in picked) {
  row <- stored[i, ]
  pr_row <- pr[pr$model == row$model & pr$arm == row$arm & pr$seed == row$seed, ]
  mode <- if (identical(pr_row$pass, "first")) "first" else "lecuyer"
  refit <- suppressWarnings(fit_stored_workflow(
    row, outer_by_seed[[as.character(row$seed)]], models[[row$model]], mode, base_stream
  ))
  check <- comparison(refit$scored, row)
  message(sprintf("%s / %s / %d (%s): max abs diff %.3g", row$model, row$arm, row$seed, mode, check$max_abs))
  stopifnot(check$within)
  stopifnot(isTRUE(all.equal(refit$scored$pr_auc, pr_row$pr_auc, tolerance = 1e-9)))
}

message(sprintf("existing reproduction: ok (%.1f s)", proc.time()[["elapsed"]] - started))
