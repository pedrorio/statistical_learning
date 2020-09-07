source("./get_last_pca_index.R")
source("./get_pca_importance.R")

get_last_pca_cummulative_variance_percentage <- function(prepped_recipe) {
	last_pca_index <- get_last_pca_index(prepped_recipe)
	spca_importance <- get_pca_importance(prepped_recipe)
	return(spca_importance["cumulative.proportion", last_pca_index])
}