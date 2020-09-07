source("./get_model.R")

plot_model_params <- function(fits, model_tag, recipe_tag) {
  return(get_model(fits, model_tag, recipe_tag)$plot + ggplot2::theme(legend.position="bottom"))
}