load_libraries <- function(libraries) {
	invisible(
	  	lapply(
		    libraries,
		    library,
		    character.only = TRUE,
		    warn.conflicts = FALSE
		)
  	)
}
