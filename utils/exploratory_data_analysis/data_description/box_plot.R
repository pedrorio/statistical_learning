box_plot <- function(data, group_variable, comparison_variable) {
	return(
		ggplot2::ggplot(
			data, 
			ggplot2::aes_string(
				x = group_variable, 
				y = comparison_variable, 
				group = group_variable,
				fill = group_variable,
				color =group_variable
				)
			) +
		ggplot2::geom_boxplot(alpha=0.4) +
		ggplot2::stat_summary(fun = mean)
	)
}