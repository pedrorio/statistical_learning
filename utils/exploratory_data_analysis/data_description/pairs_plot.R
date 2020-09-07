pairs_plot <- function(data, group_variable) {
	return(
		GGally::ggpairs(
		  data, upper = list(continuous = "density"), 
		  ggplot2::aes_string(colour = group_variable, alpha = 0.4)
		)
	)
}