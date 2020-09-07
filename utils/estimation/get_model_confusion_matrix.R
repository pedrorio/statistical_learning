source("./get_model.R")

get_model_confusion_matrix <- function(fits, model_tag, recipe_tag) {
  fit <- get_model(fits, model_tag, recipe_tag)
  return(fit$test$confusion_matrix)
}