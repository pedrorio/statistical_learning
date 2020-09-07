source("./get_last_pca_index.R")
source("./get_pca_object.R")

get_pca_importance <- function(prepped_recipe) {
	spca_data <- get_pca_object(prepped_recipe)

	number_of_rows <- 3
	number_of_columns = length(colnames(spca_data$res$rotation))

	importance <- data.frame(matrix(nrow=number_of_rows, ncol=number_of_columns))
	colnames(importance) <- colnames(spca_data$res$rotation)
	rownames(importance) <- c("standard.deviation", "proportion.of.variance", "cumulative.proportion")
	importance[rownames(importance),] <- rbind(
		spca_data$res$sdev,
		spca_data$res$sdev^2 / sum(spca_data$res$sdev^2),
		cumsum(spca_data$res$sdev^2 / sum(spca_data$res$sdev^2))
	)
	importance <- importance[,1:get_last_pca_index(prepped_recipe)]

	return(importance)
}


