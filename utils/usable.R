usable <- function(data) {
	return(data %>% dplyr::select(!where(is.factor)))
}