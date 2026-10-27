source("./get_model.R")

get_model_fit <- function(fits, model_tag, recipe_tag) {
  fit <- get_model(fits, model_tag, recipe_tag)
  metrics <- fit$test$metrics
  accuracy <- metrics$.estimate[metrics$.metric == "accuracy"]
  if (length(accuracy) != 1) {
    stop("No accuracy metric for ", model_tag, " / ", recipe_tag)
  }
  accuracy[[1]]
}