## ---- setup_data_in_classification_and_discrimination
invisible(source("../libraries.R", chdir = TRUE))

## ---- fits_in_classification_and_discrimination
# new_fits
file <- "../results/classification_and_discrimination_fits.Rda"
if (file.exists(file)) {
  fits <- readRDS(file)
} else {
	data <- load_recoded_data("../data/winequality-red.csv", "quality")
	data_split <- rsample::initial_split(data, prop = .8)
	train_data <- rsample::training(data_split)
	test_data  <- rsample::testing(data_split)
	training_folds <- rsample::vfold_cv(train_data, v = 10, repeats = 10, strata = quality)
	metrics <- yardstick::metric_set(yardstick::accuracy)
	selection_metric <- "accuracy"
	fits <- 
		list(model_config=model_specs, recipe_config=recipe_specs(train_data, "quality")) %>%
		purrr::cross() %>%
		purrr::map(~pipeline(.$model_config, .$recipe_config, metrics, selection_metric, training_folds, train_data, data_split))
  		# furrr::future_map(~pipeline(.$model_config, .$recipe_config, metrics, selection_metric, training_folds, train_data, data_split))
  	saveRDS(fits, file)
}



## ---- lr_fd_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "lr", "fd"), 4)*100, "\\%"))
## ---- lr_fd_params_in_classification_and_discrimination
get_model_params(fits, "lr", "fd")

## ---- lr_sfd_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "lr", "sfd"), 4)*100, "\\%"))
## ---- lr_sfd_params_in_classification_and_discrimination
get_model_params(fits, "lr", "sfd")

## ---- lr_sfpc_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "lr", "sfpc"), 4)*100, "\\%"))
## ---- lr_sfpc_params_in_classification_and_discrimination
get_model_params(fits, "lr", "sfpc")

## ---- plot_lr_params_in_classification_and_discrimination
plot_model_params(fits, "lr", "fd")
plot_model_params(fits, "lr", "sfd")
plot_model_params(fits, "lr", "sfpc")



## ---- svm_poly_fd_params_in_classification_and_discrimination
get_model_params(fits, "svm_poly", "fd")
## ---- svm_poly_fd_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "svm_poly", "fd"), 4)*100, "\\%"))

## ---- svm_poly_sfd_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "svm_poly", "sfd"), 4)*100, "\\%"))
## ---- svm_poly_sfd_params_in_classification_and_discrimination
get_model_params(fits, "svm_poly", "sfd")

## ---- svm_poly_sfpc_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "svm_poly", "sfpc"), 4)*100, "\\%"))
## ---- svm_poly_sfpc_params_in_classification_and_discrimination
get_model_params(fits, "svm_poly", "sfpc")

## ---- plot_svm_poly_params_in_classification_and_discrimination
plot_model_params(fits, "svm_poly", "fd")
plot_model_params(fits, "svm_poly", "sfd")
plot_model_params(fits, "svm_poly", "sfpc")



## ---- svm_radial_fd_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "svm_radial", "fd"), 4)*100, "\\%"))
## ---- svm_radial_fd_params_in_classification_and_discrimination
get_model_params(fits, "svm_radial", "fd")

## ---- svm_radial_sfd_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "svm_radial", "sfd"), 4)*100, "\\%"))
## ---- svm_radial_sfd_params_in_classification_and_discrimination
get_model_params(fits, "svm_radial", "sfd")

## ---- svm_radial_sfpc_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "svm_radial", "sfpc"), 4)*100, "\\%"))
## ---- svm_radial_sfpc_params_in_classification_and_discrimination
get_model_params(fits, "svm_radial", "sfpc")

## ---- plot_svm_radial_params_in_classification_and_discrimination
plot_model_params(fits, "svm_radial", "fd")
plot_model_params(fits, "svm_radial", "sfd")
plot_model_params(fits, "svm_radial", "sfpc")



## ---- lda_fd_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "lda", "fd"), 4)*100, "\\%"))
## ---- lda_fd_params_in_classification_and_discrimination
get_model_params(fits, "lda", "fd")

## ---- lda_sfd_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "lda", "sfd"), 4)*100, "\\%"))
## ---- lda_sfd_params_in_classification_and_discrimination
get_model_params(fits, "lda", "sfd")

## ---- lda_sfpc_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "lda", "sfpc"), 4)*100, "\\%"))
## ---- lda_sfpc_params_in_classification_and_discrimination
get_model_params(fits, "lda", "sfpc")

## ---- plot_lda_params_in_classification_and_discrimination
plot_model_params(fits, "lda", "fd")
plot_model_params(fits, "lda", "sfd")
plot_model_params(fits, "lda", "sfpc")



## ---- fda_fd_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "fda", "fd"), 4)*100, "\\%"))
## ---- fda_fd_params_in_classification_and_discrimination
get_model_params(fits, "fda", "fd")

## ---- fda_sfd_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "fda", "sfd"), 4)*100, "\\%"))
## ---- fda_sfd_params_in_classification_and_discrimination
get_model_params(fits, "fda", "sfd")

## ---- fda_sfpc_accuracy_in_classification_and_discrimination
cat(paste0(round(get_model_fit(fits, "fda", "sfpc"), 4)*100, "\\%"))
## ---- fda_sfpc_params_in_classification_and_discrimination
get_model_params(fits, "fda", "sfpc")

## ---- plot_fda_params_in_classification_and_discrimination
plot_model_params(fits, "fda", "fd")
plot_model_params(fits, "fda", "sfd")
plot_model_params(fits, "fda", "sfpc")



## ---- accuracy_comparison_table_in_classification_and_discrimination
accuracy_table(fits, "Classification accuracy")


# stopCluster(cl)