source("./get_last_pca_index.R")
source("./get_pca_object.R")

get_pca_scores <- function(prepped_recipe) {
	return(get_pca_object(prepped_recipe)$res$x[,1:get_last_pca_index(prepped_recipe)])
}