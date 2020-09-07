source("./get_pca_object.R")

plot_top_pca_loading_contributions <- function(prepped_recipe) {	
	return(
		tidy(get_pca_object(spca_prepped_recipe))  %>%
		dplyr::filter(component %in% unlist(seq(1,get_last_pca_index(spca_prepped_recipe)) %>% purrr::map(~str_interp("PC${.}")), use.names=FALSE)) %>%
		dplyr::group_by(component) %>%
		dplyr::top_n(4, abs(value)) %>%
		dplyr::ungroup() %>%
		dplyr::mutate(terms = tidytext::reorder_within(terms, abs(value), component)) %>%
		ggplot(aes(abs(value), terms, fill = value > 0)) +
		  geom_col() +
		  facet_wrap(~component, scales = "free_y") +
		  scale_y_reordered() +
		  labs(
		    x = "Absolute value of contribution",
		    y = NULL, fill = "Positive"
		  )
	  )
}