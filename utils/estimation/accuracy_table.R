source("./get_model.R")
source("../latex_table.R")

accuracy_table <- function(fits, caption) {
  estimate_accuracy <- function(fit) {
    metrics <- fit$test$metrics
    accuracy <- metrics$.estimate[metrics$.metric == "accuracy"]
    if (length(accuracy) != 1) {
      stop("No accuracy metric for ", fit$model_config$tag, " / ", fit$recipe_config$tag)
    }
    accuracy[[1]]
  }
  model_accuracies <- purrr::map_chr(fits, function(fit) paste0(round(estimate_accuracy(fit), 4) * 100, "%"))
  model_names <- unique(purrr::map_chr(fits, function(fit) fit$model_config$name))
  recipe_names <- unique(purrr::map_chr(fits, function(fit) fit$recipe_config$name))
  accuracy_comparison <- t(matrix(
    model_accuracies,
    nrow = length(model_names), ncol = length(recipe_names),
    dimnames = list(
      model_names,
      recipe_names
    )
  ))
  return(latex_table(accuracy_comparison, caption))
}