latex_table <- function(data, caption, latex_options = c("scale_down", "hold_position"), position = "center", digits = 2) {
	return(
		knitr::kable(data, format = "latex", caption = caption, booktabs = TRUE, digits = digits) %>% 
		kableExtra::kable_styling(latex_options = latex_options, position = position)
	)
}