outlier_detection_plot <- function(data, group_variable) {

	group_variable_classes <- sort(unique(data[[group_variable]]))
	column_names <- colnames(data %>% dplyr::select(!where(is.factor)))
	data <- as.data.frame(data)
	color_scale <- scales::hue_pal()(length(group_variable_classes))
	pc_num <- get_last_pca_index(get_recoded_winsorised_pca_recipe(data, "quality") %>% recipes::prep())

	for (i in group_variable_classes) {

	    selection <- data[[group_variable]] == i
	    color <- group_variable_classes %>% purrr::detect_index(~.==i) %>% color_scale[.]

		plot(
			rrcov::PcaHubert(
				data[selection, column_names], 
				alpha = 1, k = pc_num, scale = TRUE, crit.pca.distances = 0.999
			),
			col = color, pch = 16, main = NULL
		)
		legend("topleft", legend = i, pch = 16, col = color)
		title(stringr::str_interp("Outlier detection in wines with ${i} quality"))
  	}
}