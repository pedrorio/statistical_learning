fd <- function(train_data, outcome_variable) {
	recipe_formula <- formula(stringr::str_interp("${outcome_variable} ~ ."))
	return(
		list(
			recipe = recipes::recipe(recipe_formula, data = train_data) %>%
								recipes::step_naomit(recipes::all_numeric()) %>%
								recipes::step_zv(recipes::all_predictors()) %>% 
								themis::step_rose(recipes::all_outcomes()) %>% 								
								recipes::step_nzv(recipes::all_predictors()) %>% 
								recipes::step_corr(threshold = 0.80, recipes::all_numeric()) %>%
								recipes::step_lincomb(recipes::all_numeric()) %>%
								step_winsorise(recipes::all_numeric()),
			name = "Filtered dataset",
			tag = "fd"
		)
	)
}