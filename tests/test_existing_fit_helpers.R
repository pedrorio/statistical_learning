source("libraries.R")
source("reevaluation/step_winsorise.R")
source("reevaluation/metrics.R")
source("reevaluation/recipes.R")
source("reevaluation/models.R")
source("reevaluation/fit_reevaluation.R")

seeds <- 2021:2025
loaded <- load_recode_and_score("data/winequality-red.csv")
data <- loaded$data

# Labels: 1599 wines, quality 7 and 8 are high (217), and "high" is the
# second level, which every event_level = "second" call relies on.
stopifnot(nrow(data) == 1599, identical(levels(data$quality), c("low", "high")))
stopifnot(sum(data$quality == "high") == 217, sum(loaded$score >= 7) == 217)

# Outer splits: stratified 80/20, disjoint, covering every row, 44 high in each
# test split, and the same rows for the same seed.
outers <- make_outer_splits(data, loaded$score, seeds = seeds, v = 10, repeats = 10)
for (outer in outers) {
  stopifnot(length(outer$train_index) == 1278, length(outer$test_index) == 321)
  stopifnot(length(intersect(outer$train_index, outer$test_index)) == 0)
  stopifnot(setequal(c(outer$train_index, outer$test_index), seq_len(1599)))
  stopifnot(sum(outer$test$quality == "high") == 44)
  stopifnot(identical(outer$score_test$quality, loaded$score[outer$test_index]))
  # Inner folds only ever see the training rows.
  stopifnot(nrow(outer$folds) == 100, nrow(outer$folds$splits[[1]]$data) == 1278)
}
again <- make_outer_splits(data, loaded$score, seeds = 2023, v = 10, repeats = 10)[[1]]
stopifnot(identical(again$test_index, outers[[3]]$test_index))
stopifnot(!identical(outers[[1]]$test_index, outers[[2]]$test_index))
stopifnot(inherits(try(make_outer_splits(data, loaded$score[-1], 2021, 2, 1), silent = TRUE), "try-error"))

# The stored fits used exactly these splits.
for (i in seq_along(seeds)) {
  saved <- readRDS(sprintf("results/reevaluation/lgb__none__%d.rds", seeds[[i]]))
  stopifnot(identical(saved$train_index, outers[[i]]$train_index))
  stopifnot(identical(saved$test_index, outers[[i]]$test_index))
}

# Score folds hold the same rows as the class folds, with the score outcome.
outer <- outers[[1]]
for (k in c(1, 37, 100)) {
  a <- outer$folds$splits[[k]]
  b <- outer$score_folds$splits[[k]]
  stopifnot(identical(as.integer(a, data = "assessment"), as.integer(b, data = "assessment")))
  stopifnot(identical(rsample::assessment(b)$quality, outer$score_train$quality[as.integer(a, data = "assessment")]))
}
stopifnot(inherits(try(retarget_rset(outer$folds, outer$score_train[-1, ]), silent = TRUE), "try-error"))

# Class weights come from the outer training split: n / (2 n_c), so each class
# carries half the total weight. Test rows get weight 1.
n_high <- sum(outer$train$quality == "high")
n_low <- 1278 - n_high
stopifnot(isTRUE(all.equal(outer$class_weights, c(low = 1278 / (2 * n_low), high = 1278 / (2 * n_high)))))
w <- as.numeric(outer$weighted_train$case_weight)
stopifnot(isTRUE(all.equal(sum(w[outer$train$quality == "high"]), 639)))
stopifnot(isTRUE(all.equal(sum(w[outer$train$quality == "low"]), 639)))
stopifnot(all(as.numeric(outer$weighted_test$case_weight) == 1))

# Leakage guard on out-of-fold rows.
fails <- function(expr) inherits(try(expr, silent = TRUE), "try-error")
stopifnot(is.null(assert_oof_excludes_test(1:5, 11:15, 1:10, 5)))
stopifnot(fails(assert_oof_excludes_test(c(1, 6), 11:15, 1:10, 5)))
stopifnot(fails(assert_oof_excludes_test(1:5, c(11:14, 3), 1:10, 5)))

# Protected paths: the 105 original fits are never refit or rewritten.
stopifnot(protected_fit_path("results/reevaluation/svm_radial__none__2021.rds"))
stopifnot(!protected_fit_path("results/reevaluation/xgb_full__none__2021.rds"))
stopifnot(!protected_fit_path("results/reevaluation/lgb__weights__2021.rds"))
models <- reevaluation_models()
dir <- tempfile("helpers-")
dir.create(dir)
job <- list(model = models$lr, arm = "none", seed = 2021L, path = file.path(dir, "lr__none__2021.rds"))
stopifnot(fails(suppressMessages(fit_job(job, c(a = "x"), 10, 10))))
stopifnot(!file.exists(job$path))
invisible(file.copy("results/reevaluation/lr__none__2021.rds", job$path))
before <- tools::md5sum(job$path)
kept <- suppressMessages(fit_job(job, c(a = "x"), 10, 10))
stopifnot(identical(kept, readRDS("results/reevaluation/lr__none__2021.rds")$metrics))
stopifnot(identical(tools::md5sum(job$path), before))

# Cache keys: a stored fit is reused only when every key field matches.
md5 <- c(a = "1", b = "2")
base_job <- list(model = models$lgb, arm = "weights", seed = 2021L)
k <- job_key(base_job, md5, 10, 10)
stopifnot(identical(k, job_key(base_job, md5, 10L, 10L)))
stopifnot(!identical(k, job_key(modifyList(base_job, list(seed = 2022L)), md5, 10, 10)))
stopifnot(!identical(k, job_key(modifyList(base_job, list(arm = "none")), md5, 10, 10)))
stopifnot(!identical(k, job_key(list(model = models$xgb_full, arm = "weights", seed = 2021L), md5, 10, 10)))
stopifnot(!identical(k, job_key(base_job, md5, 5, 10)))
stopifnot(!identical(k, job_key(base_job, md5, 10, 5)))
stopifnot(!identical(k, job_key(base_job, c(a = "1", b = "3"), 10, 10)))

# A stored fit is reused only when its key matches; a stale key refits and
# rewrites the file. A one-candidate score model on 2 folds keeps this cheap.
small <- make_outer_splits(data, loaded$score, seeds = 2021, v = 2, repeats = 1)[[1]]
cached_job <- list(
  model = models$score_lin, arm = "score", seed = 2021L,
  train = small$score_train, test = small$score_test, folds = small$score_folds,
  class_weights = small$class_weights, test_class = small$test$quality,
  train_index = small$train_index, test_index = small$test_index,
  weights_supported = TRUE, grid_override = models$score_lin$grid[13, ],
  path = file.path(dir, "score_lin__score__2021.rds")
)
first <- suppressMessages(fit_job(cached_job, md5, 2, 1))
stopifnot(identical(first$status, "ok"))
stopifnot(identical(readRDS(cached_job$path)$key, job_key(cached_job, md5, 2, 1)))
marked <- readRDS(cached_job$path)
marked$metrics$detail <- "from cache"
saveRDS(marked, cached_job$path)
stopifnot(identical(suppressMessages(fit_job(cached_job, md5, 2, 1))$detail, "from cache"))
stale <- suppressMessages(fit_job(cached_job, c(a = "1", b = "9"), 2, 1))
stopifnot(is.na(stale$detail), identical(stale$bal_accuracy, first$bal_accuracy))
stopifnot(identical(readRDS(cached_job$path)$key$sources, c(a = "1", b = "9")))

# Stored added fits: each file's metrics are the summary row, its cut is the
# one its saved out-of-fold predictions give, out-of-fold rows stay inside the
# training split, and its saved test predictions rescore to the stored metrics.
added <- readRDS("results/reevaluation/metrics_added.rds")
stopifnot(nrow(added) == 35, all(added$status == "ok"))
for (i in seq_len(nrow(added))) {
  row <- added[i, ]
  saved <- readRDS(sprintf("results/reevaluation/%s__%s__%d.rds", row$model, row$arm, row$seed))
  stopifnot(identical(saved$metrics, row))
  stopifnot(all(saved$oof$.row >= 1 & saved$oof$.row <= 1278), nrow(saved$test) == 321)
  stopifnot(length(intersect(saved$train_index[saved$oof$.row], saved$test_index)) == 0)
  if (identical(row$arm, "score")) {
    stopifnot(identical(row$threshold, choose_score_threshold(saved$oof$quality, saved$oof$.pred)))
    rescored <- score_at_threshold(saved$test$quality, saved$test$.pred, row$threshold)
  } else {
    stopifnot(identical(row$threshold, choose_threshold(saved$oof$quality, saved$oof$.pred_high)))
    rescored <- score_at_threshold(saved$test$quality, saved$test$.pred_high, row$threshold)
  }
  for (field in c("bal_accuracy", "roc_auc", "pr_auc", "accuracy", "tp", "fp", "tn", "fn")) {
    stopifnot(isTRUE(all.equal(rescored[[field]], row[[field]], tolerance = 1e-12)))
  }
  stopifnot(identical(as.character(saved$test$quality), as.character(data$quality[saved$test_index])))
}

message("existing fit helpers: ok")
