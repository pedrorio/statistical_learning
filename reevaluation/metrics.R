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

score_at_threshold <- function(truth, prob_high, threshold) {
  truth <- as_quality(truth)
  predicted <- as_quality(ifelse(prob_high >= threshold, "high", "low"))
  tibble::tibble(
    bal_accuracy = unname(yardstick::bal_accuracy_vec(truth, predicted, event_level = "second")),
    accuracy = unname(yardstick::accuracy_vec(truth, predicted)),
    roc_auc = unname(yardstick::roc_auc_vec(truth, prob_high, event_level = "second")),
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
    tp = 0L,
    fp = 0L,
    tn = n_low,
    fn = n_high,
    threshold = NA_real_
  )
}
