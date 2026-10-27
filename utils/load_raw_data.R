load_raw_data <- function(location) {
	data_red <- readr::read_delim(location, ";", col_types = "dddddddddddf")
	names(data_red) <- make.names(names(data_red), unique = TRUE)
	data_red$type <- as.factor(rep('red', nrow(data_red)))
	data <- data_red
	return(data)
}