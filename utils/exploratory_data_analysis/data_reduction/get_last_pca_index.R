source("./get_pca_object.R")

get_last_pca_index <- function(prepped_recipe) {
	spca_data <- get_pca_object(prepped_recipe)
	return(spca_data$num_comp)
}