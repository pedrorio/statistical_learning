svm_poly <- list(
        model = parsnip::svm_poly(degree = tune::tune(), scale_factor = tune::tune(), cost = tune::tune()) %>% 
                parsnip::set_engine("kernlab") %>% 
                parsnip::set_mode("classification"),
        name = "Support Vector Machine (polynomial kernel)",
        tag = "svm_poly",
        grid =  dials::grid_regular(dials::degree(), dials::scale_factor(),  dials::cost(), levels = 3)
    )