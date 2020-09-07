source("./get_model.R")

get_model_fit <- function(fits, model_tag, recipe_tag) {
  fit <- get_model(fits, model_tag, recipe_tag)
  return(fit$test$metrics[1,][[".estimate"]])
}