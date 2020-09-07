source("../../recipes/index.R", chdir=TRUE)
source("./filtered_dataset.R")
source("./standardised_filtered_dataset.R")
source("./standardised_filtered_principal_components.R")

recipe_specs <- function(data, outcome_variable) {
	return(
		list(
			fd(data, outcome_variable),
			sfd(data, outcome_variable),
			sfpc(data, outcome_variable)
		)
	)
}