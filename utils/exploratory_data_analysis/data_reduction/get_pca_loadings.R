source("./get_last_pca_index.R")
source("./get_pca_object.R")

get_pca_loadings <- function(prepped_recipe) {
	spca_data <- get_pca_object(prepped_recipe)
	return(spca_data$res$rotation[,1:get_last_pca_index(prepped_recipe)])
}