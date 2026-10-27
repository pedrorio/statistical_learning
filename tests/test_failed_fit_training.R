# Acceptance for fix-failed-fit-recording: a fit that errors is recorded as a
# row with status "na" and its error, and the other jobs in the run still finish.
source("libraries.R")
source("reevaluation/step_winsorise.R")
source("reevaluation/metrics.R")
source("reevaluation/recipes.R")
source("reevaluation/models.R")
source("reevaluation/fit_reevaluation.R")

loaded <- load_recode_and_score("data/winequality-red.csv")
keep <- withr::with_seed(11, unlist(lapply(split(seq_len(1599), loaded$data$quality), function(rows) {
  sample(rows, round(300 * length(rows) / 1599))
})))
outer <- make_outer_splits(loaded$data[sort(keep), ], loaded$score[sort(keep)], seeds = 2021, v = 2, repeats = 2)[[1]]
models <- reevaluation_models()
dir <- tempfile("failed-")
dir.create(dir)

job_for <- function(tag, grid) {
  list(
    model = models[[tag]], arm = "none", seed = 2021L,
    train = outer$train, test = outer$test, folds = outer$folds,
    class_weights = outer$class_weights, test_class = NULL,
    train_index = outer$train_index, test_index = outer$test_index,
    weights_supported = TRUE, grid_override = grid,
    path = file.path(dir, sprintf("%s__none__2021.rds", tag))
  )
}
jobs <- list(
  job_for("lgb", models$lgb$grid_fn(5)[1:2, ]),
  # Not a parameter of this model, so tuning throws.
  job_for("xgb_full", tibble::tibble(not_a_parameter = c(1, 2)))
)

# The same per-job call fit_reevaluation makes.
out <- parallel::mclapply(jobs, fit_job, source_md5 = c(a = "1"), v = 2, repeats = 2,
  mc.cores = 2, mc.preschedule = FALSE, mc.set.seed = TRUE)
crashed <- vapply(out, inherits, logical(1), what = "try-error")
if (any(crashed)) {
  stop("The run crashed instead of recording the failed fit: ",
    paste(vapply(out[crashed], as.character, character(1)), collapse = "; "))
}
metrics <- dplyr::bind_rows(out)
stopifnot(nrow(metrics) == 2, identical(metrics$model, c("lgb", "xgb_full")))
stopifnot(identical(metrics$status, c("ok", "na")))
failed <- metrics[metrics$model == "xgb_full", ]
stopifnot(is.character(failed$detail), nzchar(failed$detail), is.na(failed$bal_accuracy))
stopifnot(identical(readRDS(jobs[[2]]$path)$metrics$status, "na"))
message("failed fit training: ok")
