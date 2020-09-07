## ---- setup_in_data_reduction
invisible(source("../../libraries.R", chdir = TRUE))

## ---- load_recoded_data_in_data_reduction
data <- load_recoded_data("../../data/winequality-red.csv", "quality")

## ---- compute_the_top_standard_principal_components_in_data_reduction
spca_recipe <- get_recoded_winsorised_pca_recipe(data, "quality") 
spca_prepped_recipe <- spca_recipe %>% recipes::prep()

## ---- top_standard_principal_components_table_in_data_reduction
latex_table(round(get_pca_importance(spca_prepped_recipe), 2), "Standardised Principal Components Explained Variance", latex_options = c("hold_position"))

## ---- top_standard_principal_components_loadings_in_data_reduction
latex_table(round(get_pca_loadings(spca_prepped_recipe), 2), "Standardised Principal Components Loadings", latex_options = c("hold_position"))

## ---- last_standard_principal_component_index_in_data_reduction
cat(paste0(get_last_pca_index(spca_prepped_recipe)))

## ---- last_standard_principal_component_percentage_explained_in_data_reduction
cat(paste0(round(get_last_pca_cummulative_variance_percentage(spca_prepped_recipe), 4)*100, "\\%"))

## ---- plot_top_standard_principal_components_loadings_contribution_in_data_reduction
plot_top_pca_loading_contributions(spca_prepped_recipe)