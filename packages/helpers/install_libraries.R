install_libraries <- function(libraries) {
	invisible(
	  	lapply(
		    libraries,
		    renv::install,
		    prompt = FALSE
		)
  	)
}