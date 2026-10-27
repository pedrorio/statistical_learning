source("libraries.R")
source("reevaluation/step_winsorise.R")
source("reevaluation/metrics.R")
source("reevaluation/recipes.R")
source("reevaluation/models.R")
source("reevaluation/fit_reevaluation.R")

# A stratified 300-row subset of the wine data, one outer split, 2 by 2 CV,
# and a two-point grid, run through fit_job as fit_reevaluation runs each job.
loaded <- load_recode_and_score("data/winequality-red.csv")
keep <- withr::with_seed(11, unlist(lapply(split(seq_len(1599), loaded$data$quality), function(rows) {
  sample(rows, round(300 * length(rows) / 1599))
})))
data <- loaded$data[sort(keep), ]
outer <- make_outer_splits(data, loaded$score[sort(keep)], seeds = 2021, v = 2, repeats = 2)[[1]]
n_train <- nrow(outer$train)
models <- reevaluation_models()
dir <- tempfile("training-")
dir.create(dir)

# Capture the tuning results the real call selects from.
tuned <- NULL
invisible(trace("select_best", where = asNamespace("tune"), print = FALSE,
  tracer = quote(assign("tuned", x, envir = globalenv()))))

train_one <- function(tag, arm, grid) {
  weighted <- identical(arm, "weights")
  job <- list(
    model = models[[tag]], arm = arm, seed = 2021L,
    train = if (weighted) outer$weighted_train else outer$train,
    test = if (weighted) outer$weighted_test else outer$test,
    folds = if (weighted) outer$weighted_folds else outer$folds,
    class_weights = outer$class_weights, test_class = NULL,
    train_index = outer$train_index, test_index = outer$test_index,
    weights_supported = TRUE, grid_override = grid,
    path = file.path(dir, sprintf("%s__%s__2021.rds", tag, arm))
  )
  metrics <- suppressMessages(suppressWarnings(fit_job(job, c(a = "1"), 2, 2)))
  saved <- readRDS(job$path)
  stopifnot(identical(metrics$status, "ok"))

  # Tuning ran on the 2 by 2 folds of the training split only.
  stopifnot(nrow(tuned) == 4)
  for (spl in tuned$splits) {
    stopifnot(identical(spl$data, job$train))
  }
  for (r in c("Repeat1", "Repeat2")) {
    held <- unlist(lapply(tuned$splits[tuned$id == r], as.integer, data = "assessment"))
    stopifnot(setequal(held, seq_len(n_train)), !anyDuplicated(held))
  }

  # The selected point is a grid point, and it is the one with the best mean
  # balanced accuracy over the four folds.
  cv <- tune::collect_metrics(tuned)
  stopifnot(all(cv$n == 4), nrow(cv) == 2, cv$mean[[1]] != cv$mean[[2]])
  param_cols <- setdiff(names(cv), c(".metric", ".estimator", "mean", "n", "std_err", ".config"))
  stopifnot(setequal(param_cols, names(grid)))
  best <- cv[which.max(cv$mean), param_cols]
  texts <- vapply(seq_len(nrow(grid)), function(i) params_text(grid[i, param_cols]), character(1))
  stopifnot(metrics$params %in% texts)
  stopifnot(identical(metrics$params, params_text(best)))

  # Out-of-fold predictions: every training row once per repeat, no test row.
  stopifnot(nrow(saved$oof) == 2 * n_train)
  stopifnot(all(tabulate(saved$oof$.row, n_train) == 2))
  stopifnot(length(intersect(outer$train_index[saved$oof$.row], outer$test_index)) == 0)
  stopifnot(nrow(saved$test) == length(outer$test_index))

  # The cut comes from those out-of-fold probabilities.
  stopifnot(identical(metrics$threshold, choose_threshold(saved$oof$quality, saved$oof$.pred_high)))
  message(sprintf("training %s / %s: %s, cut %.2f", tag, arm, metrics$params, metrics$threshold))
}

p <- predictor_count(filtered_recipe(outer$train, "none"), outer$train)
xgb_grid <- models$xgb_full$grid_fn(p)[c(1, 2), ]
xgb_grid$sample_size <- 1
train_one("xgb_full", "none", xgb_grid)
lgb_grid <- models$lgb$grid_fn(p)
train_one("lgb", "weights", lgb_grid[order(lgb_grid$trees)[1:2], ])

invisible(untrace("select_best", where = asNamespace("tune")))
message("existing training: ok")
