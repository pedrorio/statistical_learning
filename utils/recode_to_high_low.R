recode_to_high_low <- function(data, factor_name) {
	return(
		data[[factor_name]] %>% 
		forcats::fct_recode(
				low = "3", low = "4", low = "5", low = "6",
				high = "7", high = "8"
		)
	)
}