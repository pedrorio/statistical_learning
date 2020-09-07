load_raw_data <- function(location) {
	data_red <-
	readr::read_delim(location, ";", col_types = "dddddddddddf") %>% 
	set_tidy_names(syntactic = TRUE, quiet = TRUE)
	data_red$type <- as.factor(rep('red', nrow(data_red)))
	data <- data_red
	return(data)
}