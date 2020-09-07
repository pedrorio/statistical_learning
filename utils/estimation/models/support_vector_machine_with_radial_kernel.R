svm_radial <- list(
	    model = parsnip::svm_rbf(rbf_sigma = tune::tune(), cost = tune::tune()) %>%
	    		parsnip::set_engine("kernlab") %>% 
	    		parsnip::set_mode("classification"),
	   	name = "Support Vector Machine (radial kernel)",
	   	tag = "svm_radial",
	   	grid = dials::grid_regular(dials::rbf_sigma(), dials::cost(), levels = 5)
	)