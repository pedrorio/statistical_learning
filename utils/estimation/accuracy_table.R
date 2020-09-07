source("./get_model.R")
source("../latex_table.R")

accuracy_table <- function(fits, caption) {
  model_accuracies <- fits %>% furrr::future_map(~.$test$metrics[1,][[".estimate"]]) %>% purrr::map(~paste0(round(., 4) * 100, "%"))
  model_names <- fits %>% furrr::future_map(~.$model_config$name) %>% unlist() %>% unique()
  recipe_names <- fits %>% furrr::future_map(~.$recipe_config$name) %>% unlist() %>% unique()
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