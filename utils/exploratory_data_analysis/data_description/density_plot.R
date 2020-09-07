density_plot <- function(data, group_variable, comparison_variable) {
	return(
			ggplot2::ggplot(
				data, 
				aes_string(x=comparison_variable, color=group_variable, fill=group_variable)
			) + ggplot2::geom_density(alpha=0.4)
	)
}