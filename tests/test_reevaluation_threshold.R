source("reevaluation/metrics.R")

truth <- factor(c("low", "low", "high", "high"), levels = c("low", "high"))
prob <- c(0.1, 0.2, 0.8, 0.9)
stopifnot(identical(choose_threshold(truth, prob), 0.21))

scored <- score_at_threshold(truth, prob, 0.21)
stopifnot(isTRUE(all.equal(scored$bal_accuracy, 1)))
stopifnot(isTRUE(all.equal(scored$roc_auc, 1)))
stopifnot(scored$tp == 2 && scored$fp == 0 && scored$tn == 2 && scored$fn == 0)
prevalence <- mean(truth == "high")
stopifnot(is.finite(scored$pr_auc) && scored$pr_auc > prevalence)
stopifnot(is.finite(scored$precision) && scored$precision > prevalence)
stopifnot(is.finite(scored$recall) && scored$recall > prevalence)
stopifnot(isTRUE(all.equal(scored$pr_auc, 1)))
stopifnot(isTRUE(all.equal(scored$precision, 1)))
stopifnot(isTRUE(all.equal(scored$recall, 1)))

raw_score <- score_at_threshold(truth, c(1, 2, 8, 9), 6.5)
stopifnot(isTRUE(all.equal(raw_score$bal_accuracy, 1)))
stopifnot(is.finite(raw_score$pr_auc) && raw_score$pr_auc > prevalence)
stopifnot(is.finite(raw_score$roc_auc) && raw_score$roc_auc > 0.5)
stopifnot(is.finite(raw_score$precision) && is.finite(raw_score$recall))

baseline <- guess_low_metrics(truth)
stopifnot(isTRUE(all.equal(baseline$bal_accuracy, 0.5)))
stopifnot(isTRUE(all.equal(baseline$roc_auc, 0.5)))
stopifnot(isTRUE(all.equal(baseline$accuracy, 0.5)))
stopifnot(baseline$tp == 0 && baseline$fp == 0 && baseline$tn == 2 && baseline$fn == 2)
stopifnot(is.na(baseline$pr_auc) && is.na(baseline$precision))
stopifnot(isTRUE(all.equal(baseline$recall, 0)))

truth_score <- c(4, 5, 6, 7, 8)
pred_score <- c(3, 4, 5, 7, 9)
cut <- choose_score_threshold(truth_score, pred_score)
cut_class <- score_at_threshold(
  factor(ifelse(truth_score >= 7, "high", "low"), levels = c("low", "high")),
  pred_score,
  cut
)
stopifnot(isTRUE(all.equal(cut_class$bal_accuracy, 1)))
stopifnot(cut > 5 && cut <= 7)
leaked <- choose_score_threshold(c(truth_score, 6), c(pred_score, 100))
stopifnot(!isTRUE(all.equal(cut, leaked)))

metric_df <- tibble::tibble(quality = c(5, 6, 7, 8), .pred = c(4, 5, 7, 9))
metric <- bal_accuracy_at_6_5(metric_df, quality, .pred)
stopifnot(isTRUE(all.equal(metric$.estimate, 1)))
stopifnot(identical(attr(bal_accuracy_at_6_5, "direction"), "maximize"))

message("threshold ok")
