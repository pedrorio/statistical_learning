level_order <- c("low", "high")

as_quality <- function(x) {
  factor(x, levels = level_order)
}

choose_threshold <- function(truth, prob_high) {
  truth <- as_quality(truth)
  grid <- seq(1, 99) / 100
  scores <- vapply(grid, function(threshold) {
    predicted <- as_quality(ifelse(prob_high >= threshold, "high", "low"))
    yardstick::bal_accuracy_vec(truth, predicted, event_level = "second")
  }, numeric(1))
  grid[[which.max(scores)]]
}

# The score models predict the raw quality. The same rule as the probability
# cut: 99 interior points, and the first maximum of balanced accuracy wins.
# Only the vectors passed here are searched. Callers pass out-of-fold scores.
choose_score_threshold <- function(truth_score, pred_score) {
  truth_score <- as.numeric(truth_score)
  pred_score <- as.numeric(pred_score)
  if (length(truth_score) != length(pred_score) || length(truth_score) == 0) {
    stop("Score threshold inputs must be the same non-zero length")
  }
  truth <- as_quality(ifelse(truth_score >= 7, "high", "low"))
  lo <- min(pred_score)
  hi <- max(pred_score)
  if (!is.finite(lo) || !is.finite(hi) || lo == hi) {
    return(6.5)
  }
  grid <- seq(lo, hi, length.out = 101)[-c(1, 101)]
  scores <- vapply(grid, function(threshold) {
    predicted <- as_quality(ifelse(pred_score >= threshold, "high", "low"))
    yardstick::bal_accuracy_vec(truth, predicted, event_level = "second")
  }, numeric(1))
  grid[[which.max(scores)]]
}

# Average precision and ROC AUC need an estimate in [0, 1]. A raw quality
# score is a ranking, so map it into (0, 1) without changing the order.
ranking_probability <- function(score) {
  score <- as.numeric(score)
  if (length(score) == 0) {
    return(score)
  }
  finite <- score[is.finite(score)]
  if (length(finite) > 0 && all(finite >= 0 & finite <= 1)) {
    return(score)
  }
  rank(score, ties.method = "average", na.last = "keep") / (length(finite) + 1)
}

score_at_threshold <- function(truth, score, threshold) {
  truth <- as_quality(truth)
  predicted <- as_quality(ifelse(score >= threshold, "high", "low"))
  ranking <- ranking_probability(score)
  tibble::tibble(
    bal_accuracy = unname(yardstick::bal_accuracy_vec(truth, predicted, event_level = "second")),
    accuracy = unname(yardstick::accuracy_vec(truth, predicted)),
    roc_auc = unname(yardstick::roc_auc_vec(truth, ranking, event_level = "second")),
    pr_auc = unname(yardstick::pr_auc_vec(truth, ranking, event_level = "second")),
    precision = unname(yardstick::precision_vec(truth, predicted, event_level = "second")),
    recall = unname(yardstick::recall_vec(truth, predicted, event_level = "second")),
    tp = sum(truth == "high" & predicted == "high"),
    fp = sum(truth == "low" & predicted == "high"),
    tn = sum(truth == "low" & predicted == "low"),
    fn = sum(truth == "high" & predicted == "low"),
    threshold = threshold
  )
}

guess_low_metrics <- function(truth) {
  truth <- as_quality(truth)
  n_low <- sum(truth == "low")
  n_high <- sum(truth == "high")
  tibble::tibble(
    bal_accuracy = 0.5,
    accuracy = n_low / length(truth),
    roc_auc = 0.5,
    pr_auc = NA_real_,
    precision = NA_real_,
    recall = 0,
    tp = 0L,
    fp = 0L,
    tn = n_low,
    fn = n_high,
    threshold = NA_real_
  )
}

# Inside the 10 by 10, a score model calls high when the prediction is at least 6.5.
# The true label is the same high/low coding: quality 7 and 8 are high.
bal_accuracy_at_6_5_vec <- function(truth, estimate, na_rm = TRUE, ...) {
  truth <- as.numeric(truth)
  estimate <- as.numeric(estimate)
  if (isTRUE(na_rm)) {
    keep <- is.finite(truth) & is.finite(estimate)
    truth <- truth[keep]
    estimate <- estimate[keep]
  }
  if (length(truth) == 0) {
    return(NA_real_)
  }
  truth_cls <- as_quality(ifelse(truth >= 7, "high", "low"))
  pred_cls <- as_quality(ifelse(estimate >= 6.5, "high", "low"))
  unname(yardstick::bal_accuracy_vec(truth_cls, pred_cls, event_level = "second"))
}

bal_accuracy_at_6_5 <- function(data, ...) {
  UseMethod("bal_accuracy_at_6_5")
}

bal_accuracy_at_6_5 <- yardstick::new_numeric_metric(
  bal_accuracy_at_6_5,
  direction = "maximize"
)

bal_accuracy_at_6_5.data.frame <- function(
  data,
  truth,
  estimate,
  na_rm = TRUE,
  ...
) {
  yardstick::numeric_metric_summarizer(
    name = "bal_accuracy_at_6_5",
    fn = bal_accuracy_at_6_5_vec,
    data = data,
    truth = !!rlang::enquo(truth),
    estimate = !!rlang::enquo(estimate),
    na_rm = na_rm
  )
}
