lr <- list(
        model = parsnip::logistic_reg(penalty = tune::tune(), mixture = tune::tune()) %>% 
                parsnip::set_engine("glmnet") %>% 
                parsnip::set_mode("classification"),
        name = "Logisic regression",
        tag = "lr",
        grid = dials::grid_regular(dials::penalty(), dials::mixture(), levels = 5)
    )