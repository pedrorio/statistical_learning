source("./get_model.R")
source("../latex_table.R")

get_model_params <- function(fits, model_tag, recipe_tag, digits = 2) {
  fit <- get_model(fits, model_tag, recipe_tag)
  parameters <- fit$best$result %>% dplyr::select(!".config")
  # model_name <- fit$model_config$name
  # parameter_tables <- latex_table(parameters, stringr::str_interp("${model_name} parameters"), latex_options = c("hold_position"), digits = digits)

  return(parameters)
  # return(parameter_tables)
}