get_pca_object <- function(prepped_recipe) {
	spca_data <- prepped_recipe$steps %>%
	purrr::map(~.) %>% 
	purrr::detect(~grepl("pca", list(.$id)))

	return(spca_data)
}