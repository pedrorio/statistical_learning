fda = list(
		model = discrim::discrim_flexible(num_terms = tune::tune(), prod_degree = tune::tune()) %>%
			    parsnip::set_engine("earth") %>% 
			    parsnip::set_mode("classification"),
		name = "Flexible discriminant analysis",
		tag = "fda",
		grid = 5
	)