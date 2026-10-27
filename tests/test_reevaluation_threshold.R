source("reevaluation/metrics.R")

truth <- factor(c("low", "low", "high", "high"), levels = c("low", "high"))
prob <- c(0.1, 0.2, 0.8, 0.9)
stopifnot(identical(choose_threshold(truth, prob), 0.21))

scored <- score_at_threshold(truth, prob, 0.21)
stopifnot(isTRUE(all.equal(scored$bal_accuracy, 1)))
stopifnot(isTRUE(all.equal(scored$roc_auc, 1)))
stopifnot(scored$tp == 2 && scored$fp == 0 && scored$tn == 2 && scored$fn == 0)

baseline <- guess_low_metrics(truth)
stopifnot(isTRUE(all.equal(baseline$bal_accuracy, 0.5)))
stopifnot(isTRUE(all.equal(baseline$roc_auc, 0.5)))
stopifnot(isTRUE(all.equal(baseline$accuracy, 0.5)))
stopifnot(baseline$tp == 0 && baseline$fp == 0 && baseline$tn == 2 && baseline$fn == 2)

message("threshold ok")
