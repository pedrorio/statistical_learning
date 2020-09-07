rda <- list(
		model = discrim::discrim_regularized(frac_common_cov = tune::tune(), frac_identity = tune::tune()) %>% 
				parsnip::set_engine("klaR") %>% 
				parsnip::set_mode("classification"),
		name = "Regularised discriminant analysis",
		tag = "rda",
		grid = 5
	)