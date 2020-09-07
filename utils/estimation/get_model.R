get_model <- function(fits, model_tag, recipe_tag) {
  fit <- fits %>% purrr::detect(~(.$model_config$tag == model_tag & .$recipe_config$tag == recipe_tag))
  return(fit)
}