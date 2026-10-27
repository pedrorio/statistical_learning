source("reevaluation/metrics.R")

near <- function(a, b) isTRUE(all.equal(a, b, tolerance = 1e-12))

# Four test rows, high is the event:
#   truth  low  low  high high
#   prob   0.10 0.40 0.35 0.80
truth <- factor(c("low", "low", "high", "high"), levels = c("low", "high"))
prob <- c(0.10, 0.40, 0.35, 0.80)

# Cut at 0.38: calls high on 0.40 (a low) and 0.80 (a high).
# TP 1, FN 1, TN 1, FP 1. Sensitivity 1/2, specificity 1/2, BA 1/2.
# Precision 1/(1+1) = 1/2, recall 1/2, accuracy 2/4.
at <- score_at_threshold(truth, prob, 0.38)
stopifnot(at$tp == 1, at$fn == 1, at$tn == 1, at$fp == 1)
stopifnot(near(at$bal_accuracy, 0.5), near(at$accuracy, 0.5))
stopifnot(near(at$precision, 0.5), near(at$recall, 0.5))

# Cut at 0.30: calls high on 0.35, 0.40, 0.80. Sensitivity 2/2, specificity 1/2, BA 3/4.
stopifnot(near(score_at_threshold(truth, prob, 0.30)$bal_accuracy, 0.75))

# ROC AUC: of the four (high, low) pairs the high scores above the low in
# (0.35, 0.10), (0.80, 0.10), (0.80, 0.40) and below in (0.35, 0.40): 3/4.
stopifnot(near(at$roc_auc, 0.75))

# PR AUC is yardstick's trapezoid under the PR curve, starting at (R 0, P 1):
#   cut 0.80 -> (R 1/2, P 1); 0.40 -> (1/2, 1/2); 0.35 -> (1, 2/3); 0.10 -> (1, 1/2)
#   area = 1/2 * 1 + 0 + 1/2 * (1/2 + 2/3) / 2 = 1/2 + 7/24 = 19/24.
stopifnot(near(at$pr_auc, 19 / 24))

# BA is 0.75 for any cut in (0.10, 0.35] and in (0.40, 0.80]. The grid is
# 0.01..0.99 and the first maximum wins, so the chosen cut is 0.11.
stopifnot(identical(choose_threshold(truth, prob), 0.11))

# A raw quality score with the same order gives the same AUCs: the ranking is
# all that ROC AUC and PR AUC see.
raw <- c(5.1, 6.2, 5.9, 7.3)
raw_at <- score_at_threshold(truth, raw, 6)
stopifnot(near(raw_at$roc_auc, 0.75), near(raw_at$pr_auc, 19 / 24))
stopifnot(near(raw_at$bal_accuracy, 0.5))
# Ranks 1, 3, 2, 4 over n + 1 = 5; values already in [0, 1] pass through.
stopifnot(near(ranking_probability(raw), c(1, 3, 2, 4) / 5))
stopifnot(identical(ranking_probability(prob), prob))

# Guess-low on one stored test split: 321 rows, 44 high. It calls nothing high,
# so precision and PR AUC are undefined here (the report fills PR AUC with the
# prevalence); BA and ROC AUC are 0.5; accuracy is 277/321.
split_truth <- factor(c(rep("low", 277), rep("high", 44)), levels = c("low", "high"))
guess <- guess_low_metrics(split_truth)
stopifnot(near(guess$bal_accuracy, 0.5), near(guess$roc_auc, 0.5))
stopifnot(near(guess$accuracy, 277 / 321), guess$tn == 277, guess$fn == 44)
stopifnot(is.na(guess$pr_auc), is.na(guess$precision), guess$recall == 0)

# A constant score is not the prevalence under yardstick's trapezoid: the curve
# runs (0, 1) -> (1, 44/321), area (1 + 44/321) / 2 = 0.569. That is why the
# baseline does not take PR AUC from pr_auc_vec.
constant_pr <- yardstick::pr_auc_vec(split_truth, rep(0, 321), event_level = "second")
stopifnot(near(constant_pr, (1 + 44 / 321) / 2))
stopifnot(abs(constant_pr - 44 / 321) > 0.4)

# Score models inside the 10 by 10: high means truth >= 7 and prediction >= 6.5.
#   truth     6    7     8  5
#   estimate  6.5  6.49  7  6.6
# Calls: high, low, high, high. Truth: low, high, high, low.
# Sensitivity 1/2, specificity 0/2, BA 1/4.
stopifnot(near(bal_accuracy_at_6_5_vec(c(6, 7, 8, 5), c(6.5, 6.49, 7, 6.6)), 0.25))
# The cut does not move with the predictions: shifting every estimate up by 0.5
# turns all four into high calls, sensitivity 1, specificity 0, BA 1/2.
stopifnot(near(bal_accuracy_at_6_5_vec(c(6, 7, 8, 5), c(6.5, 6.49, 7, 6.6) + 0.5), 0.5))

message("existing metrics: ok")
