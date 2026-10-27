library(parsnip)
library(yardstick)

source("reevaluation/models.R")

set.seed(1)
n_low <- 300
n_high <- 100
train <- data.frame(
  x1 = c(rnorm(n_low, -2), rnorm(n_high, 2)),
  x2 = rnorm(n_low + n_high),
  quality = factor(
    c(rep("low", n_low), rep("high", n_high)),
    levels = c("low", "high")
  )
)
weights <- c(
  low = nrow(train) / (2 * n_low),
  high = nrow(train) / (2 * n_high)
)

check_weighted_svm <- function(spec) {
  model <- spec %>%
    set_mode("classification") %>%
    with_class_weights(weights)
  fit <- fit(model, quality ~ ., data = train)
  prob <- predict(fit, train, type = "prob")
  auc <- roc_auc_vec(train$quality, prob$.pred_high, event_level = "second")
  stopifnot(isTRUE(auc > 0.5))
  stopifnot(
    mean(prob$.pred_high[train$quality == "high"]) >
      mean(prob$.pred_high[train$quality == "low"])
  )
}

check_weighted_svm(svm_poly(degree = 1, scale_factor = 1, cost = 1))
check_weighted_svm(svm_rbf(rbf_sigma = 0.5, cost = 1))

message("svm class weights ok")
