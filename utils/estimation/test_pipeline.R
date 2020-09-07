source("./pipeline.R")
test_pipeline <- function(fit, metrics, selection_metric, training_folds, train_data, data_split) {
  return(pipeline(fit$model_config, fit$recipe_config, metrics, selection_metric, training_folds, train_data, data_split))
}