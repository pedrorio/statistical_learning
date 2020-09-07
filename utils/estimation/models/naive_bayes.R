nb <- list(
        model = discrim::naive_Bayes(Laplace = tune::tune(), smoothness = tune::tune()) %>% 
                parsnip::set_engine("klaR") %>% 
                parsnip::set_mode("classification"),
        name = "Naive bayes",
        tag = "nb", 
        grid = dials::grid_regular(dials::Laplace(), dials::smoothness(), levels = 5)
    )