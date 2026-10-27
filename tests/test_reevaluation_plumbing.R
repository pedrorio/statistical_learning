source("libraries.R")
library(ranger, warn.conflicts = FALSE)
library(xgboost, warn.conflicts = FALSE)
library(hardhat, warn.conflicts = FALSE)
source("reevaluation/step_winsorise.R")
source("reevaluation/metrics.R")
source("reevaluation/recipes.R")
source("reevaluation/models.R")
source("reevaluation/fit_reevaluation.R")

loaded <- load_recode_and_score("data/winequality-red.csv")
outers <- make_outer_splits(loaded$data, loaded$score, seeds = 2021, v = 2, repeats = 1)
outer <- outers[[1]]
models <- reevaluation_models()
source_md5 <- vapply(source_files, file_md5, character(1))
fits_dir <- tempfile("plumbing-")
dir.create(fits_dir)

run_one <- function(tag, arm) {
  model <- models[[tag]]
  use_score <- isTRUE(model$score)
  use_case_weights <- identical(arm, "weights")
  train <- if (use_score) outer$score_train else if (use_case_weights) outer$weighted_train else outer$train
  test <- if (use_score) outer$score_test else if (use_case_weights) outer$weighted_test else outer$test
  folds <- if (use_score) outer$score_folds else if (use_case_weights) outer$weighted_folds else outer$folds
  recipe <- if (use_score) score_recipe(train) else filtered_recipe(train, arm)
  grid <- if (!is.null(model$grid_fn)) model$grid_fn(predictor_count(recipe, train)) else model$grid
  job <- list(
    model = model,
    arm = arm,
    seed = 2021,
    train = train,
    test = test,
    folds = folds,
    class_weights = outer$class_weights,
    test_class = if (use_score) outer$test$quality else NULL,
    train_index = outer$train_index,
    test_index = outer$test_index,
    weights_supported = TRUE,
    grid_override = head(grid, 2),
    path = file.path(fits_dir, sprintf("%s__%s__2021.rds", tag, arm))
  )
  metrics <- fit_job(job, source_md5, v = 2, repeats = 1)
  saved <- readRDS(job$path)
  if (!identical(metrics$status, "ok")) {
    stop(tag, " / ", arm, " failed: ", metrics$detail)
  }
  if (is.null(saved$oof) || is.null(saved$test) || nrow(saved$oof) == 0 || nrow(saved$test) != metrics$n_test) {
    stop(tag, " / ", arm, " did not save predictions")
  }
  if (length(intersect(saved$train_index, saved$test_index)) != 0) {
    stop(tag, " / ", arm, " split overlaps")
  }
  if (!all(is.finite(c(metrics$bal_accuracy, metrics$roc_auc, metrics$pr_auc, metrics$precision, metrics$recall, metrics$accuracy)))) {
    stop(tag, " / ", arm, " has a non-finite metric")
  }
  if (use_score) {
    again <- choose_score_threshold(saved$oof$quality, saved$oof$.pred)
    if (!isTRUE(all.equal(again, metrics$threshold))) {
      stop(tag, " threshold does not match the out-of-fold scores")
    }
    if (max(saved$oof$.row) > nrow(train)) {
      stop(tag, " out-of-fold rows leave the training split")
    }
  } else {
    again <- choose_threshold(saved$oof$quality, saved$oof$.pred_high)
    if (!isTRUE(all.equal(again, metrics$threshold))) {
      stop(tag, " threshold does not match the out-of-fold probabilities")
    }
  }
  message(sprintf(
    "plumbing %s / %s ba=%.3f pr=%.3f",
    tag, arm, metrics$bal_accuracy, metrics$pr_auc
  ))
  metrics
}

run_one("lgb", "weights")
run_one("xgb_full", "none")
run_one("score_lgb", "score")
run_one("score_rf", "score")
run_one("score_lin", "score")
message("plumbing ok")
