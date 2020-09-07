source("./get_pca_object.R")

get_recoded_winsorised_pca_recipe <- function(recoded_data, outcome_variable) {

	recipe_formula <- 
	formula(stringr::str_interp("${outcome_variable} ~ ."))
	
	spca_recipe <- 
	recipes::recipe(recipe_formula, data = recoded_data) %>% 
	step_winsorise(recipes::all_numeric()) %>%
	recipes::step_pca(
		recipes::all_numeric(),
		threshold = .8, 
		options = c(retx = TRUE, scale. = TRUE, center = TRUE)
	)

	return(spca_recipe)
}