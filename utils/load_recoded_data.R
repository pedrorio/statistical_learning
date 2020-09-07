source("./load_raw_data.R")
source("./recode_to_high_low.R")

load_recoded_data <- function(location, factor_name) {
	data <- load_raw_data(location)
	data[[factor_name]] <- recode_to_high_low(data, factor_name)
	return(data)
}