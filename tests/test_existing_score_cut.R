source("libraries.R")
source("reevaluation/step_winsorise.R")
source("reevaluation/metrics.R")
source("reevaluation/recipes.R")
source("reevaluation/models.R")
source("reevaluation/fit_reevaluation.R")

# One outer split, 3-fold CV, three penalised-regression candidates on the score.
loaded <- load_recode_and_score("data/winequality-red.csv")
outer <- make_outer_splits(loaded$data, loaded$score, seeds = 2021, v = 3, repeats = 1)[[1]]
model <- reevaluation_models()$score_lin
grid <- model$grid[c(1, 13, 25), ]

score_job_on <- function(test, test_class) {
  job <- list(
    model = model, arm = "score", seed = 2021,
    train = outer$score_train, test = test, folds = outer$score_folds,
    class_weights = outer$class_weights, test_class = test_class,
    train_index = outer$train_index, test_index = outer$test_index,
    weights_supported = TRUE, grid_override = grid
  )
  suppressMessages(score_job(job))
}

base <- score_job_on(outer$score_test, outer$test$quality)
stopifnot(identical(base$status, "ok"))
oof <- attr(base, "oof")

# Each fold refits the workflow on its analysis rows only, then the fixed 6.5
# cut is applied to its assessment rows. Recompute that by hand per candidate.
wf <- workflows::workflow() %>%
  workflows::add_model(model$model) %>%
  workflows::add_recipe(score_recipe(outer$score_train))
fold_pred <- function(params, split) {
  fitted <- generics::fit(tune::finalize_workflow(wf, params), rsample::analysis(split))
  predict(fitted, rsample::assessment(split))$.pred
}
cv_ba <- vapply(seq_len(nrow(grid)), function(i) {
  mean(vapply(outer$score_folds$splits, function(split) {
    bal_accuracy_at_6_5_vec(rsample::assessment(split)$quality, fold_pred(grid[i, ], split))
  }, numeric(1)))
}, numeric(1))
stopifnot(length(unique(cv_ba)) == 3)
best <- grid[which.max(cv_ba), ]
stopifnot(identical(base$params, params_text(best)))

# The saved out-of-fold scores are those fold refits, not the full-training fit.
split <- outer$score_folds$splits[[1]]
rows <- as.integer(split, data = "assessment")
saved <- oof$.pred[match(rows, oof$.row)]
stopifnot(isTRUE(all.equal(saved, fold_pred(best, split), tolerance = 1e-10)))
full <- generics::fit(tune::finalize_workflow(wf, best), outer$score_train)
stopifnot(max(abs(saved - predict(full, rsample::assessment(split))$.pred)) > 1e-6)
stopifnot(setequal(oof$.row, seq_len(nrow(outer$score_train))))

# The test-time cut is chosen from those out-of-fold scores only.
stopifnot(identical(base$threshold, choose_score_threshold(oof$quality, oof$.pred)))

# Perturb every test row: new predictors and new scores. The selected
# candidate, the out-of-fold scores and the cut do not move; the test score does.
set.seed(7)
test <- outer$score_test
predictors <- setdiff(names(test), c("quality", "type"))
test[predictors] <- lapply(test[predictors], function(x) sample(x) * 1.3)
test$quality <- sample(3:8, nrow(test), replace = TRUE)
test_class <- factor(ifelse(test$quality >= 7, "high", "low"), levels = level_order)
moved <- score_job_on(test, test_class)
stopifnot(identical(moved$params, base$params))
stopifnot(identical(moved$threshold, base$threshold))
stopifnot(identical(attr(moved, "oof"), oof))
stopifnot(!identical(attr(moved, "test_pred")$.pred, attr(base, "test_pred")$.pred))
stopifnot(moved$bal_accuracy != base$bal_accuracy)

message("existing score cut: ok")
