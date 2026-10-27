source("libraries.R")
source("reevaluation/step_winsorise.R")
source("reevaluation/metrics.R")
source("reevaluation/recipes.R")
source("reevaluation/models.R")
source("reevaluation/fit_reevaluation.R")

loaded <- load_recode_and_score("data/winequality-red.csv")
recoded <- load_recoded_data("data/winequality-red.csv", "quality")
stopifnot(isTRUE(all.equal(loaded$data, recoded)))

models <- reevaluation_models()
xgb <- models$xgb
stopifnot(nrow(xgb$grid) == 9)
stopifnot(all(c("tree_depth", "learn_rate") %in% names(xgb$grid)))
stopifnot(!any(c("min_n", "mtry", "loss_reduction", "sample_size") %in% names(xgb$grid)))
expected_grid <- dials::grid_regular(dials::tree_depth(), dials::learn_rate(), levels = 3)
stopifnot(identical(xgb$grid$tree_depth, expected_grid$tree_depth))
stopifnot(isTRUE(all.equal(xgb$grid$learn_rate, expected_grid$learn_rate)))
stopifnot(identical(rlang::quo_get_expr(xgb$model$args$trees), 500))
stopifnot(identical(rlang::quo_get_expr(xgb$model$args$min_n), 10))
stopifnot(is.null(xgb$fresh))

lgb_grid <- models$lgb$grid_fn(8)
stopifnot(nrow(lgb_grid) == 40)
stopifnot(identical(
  sort(setdiff(names(lgb_grid), ".config")),
  sort(c("trees", "learn_rate", "min_n", "mtry", "num_leaves"))
))
stopifnot(all(lgb_grid$trees >= 50 & lgb_grid$trees <= 1000))
stopifnot(all(lgb_grid$learn_rate >= 0.01 & lgb_grid$learn_rate <= 0.32))
stopifnot(all(lgb_grid$num_leaves >= 7 & lgb_grid$num_leaves <= 127))
stopifnot(identical(lgb_grid, models$lgb$grid_fn(8)))

xgb_full_grid <- models$xgb_full$grid_fn(8)
stopifnot(nrow(xgb_full_grid) == 40)
stopifnot(all(c(
  "tree_depth", "learn_rate", "min_n", "mtry", "loss_reduction", "sample_size"
) %in% names(xgb_full_grid)))
stopifnot(all(xgb_full_grid$sample_size >= 0.1 & xgb_full_grid$sample_size <= 1))
stopifnot(identical(rlang::quo_get_expr(models$xgb_full$model$args$trees), 500))

stopifnot(nrow(models$score_lin$grid) == 25)
stopifnot(all(c("penalty", "mixture") %in% names(models$score_lin$grid)))
stopifnot(nrow(models$score_rf$grid_fn(8)) == 9)
stopifnot(identical(models$lgb$arms, c("weights", "none")))
stopifnot(identical(models$score_rf$arms, "score"))
stopifnot(identical(models$lgb$model$engine, "lightgbm"))
stopifnot(identical(rlang::quo_get_expr(models$lgb$model$eng_args$num_threads), 1))
stopifnot(isTRUE(all.equal(rlang::quo_get_expr(models$lgb$model$eng_args$validation), 0.2)))

outers <- make_outer_splits(loaded$data, loaded$score, seeds = 2021, v = 10, repeats = 10)
outer <- outers[[1]]
stopifnot(length(intersect(outer$train_index, outer$test_index)) == 0)
stopifnot(nrow(outer$score_folds) == nrow(outer$folds))
stopifnot(nrow(rsample::assessment(outer$score_folds$splits[[1]])) ==
  nrow(rsample::assessment(outer$folds$splits[[1]])))
baked <- recipes::bake(recipes::prep(score_recipe(outer$score_train)), new_data = NULL)
stopifnot(identical(baked$quality, outer$score_train$quality))
p_none <- predictor_count(filtered_recipe(outer$train, "none"), outer$train)
p_weights <- predictor_count(filtered_recipe(outer$weighted_train, "weights"), outer$weighted_train)
stopifnot(identical(p_none, p_weights))
stopifnot(identical(models$lgb$grid_fn(p_none), models$lgb$grid_fn(p_weights)))

stopifnot(isTRUE(engine_honors_case_weights("lightgbm")))
stopifnot(isTRUE(engine_honors_case_weights("xgboost")))

message("added specs ok")
