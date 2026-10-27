lda <- list(
		model = parsnip::discrim_linear(penalty = tune::tune()) %>%
			    parsnip::set_engine("mda") %>% 
			    parsnip::set_mode("classification"),
		name = "Linear discriminant analysis",
		tag = "lda",
		grid = dials::grid_regular(dials::penalty(), levels = 5)
	)