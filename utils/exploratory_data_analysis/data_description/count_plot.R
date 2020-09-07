count_plot <- function(data, group_variable, limits) {
	return(
		ggplot2::ggplot(
  			data,
  			ggplot2::aes_string(x = group_variable, color = group_variable, group = group_variable)
		) + ggplot2::geom_bar(
	  		ggplot2::aes_string(fill = group_variable, color = group_variable, group = group_variable)
		) + scale_x_discrete(limits=limits)
	)
}