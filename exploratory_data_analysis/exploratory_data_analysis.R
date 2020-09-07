## ---- setup_in_the_exploratory_data_analysis
invisible(source("../libraries.R", chdir = TRUE))

## ---- load_recoded_data_and_compute_recoded_scores_in_the_exploratory_data_analysis
data <- load_recoded_data("../data/winequality-red.csv", "quality")
scores <- get_recoded_winsorised_pca_recipe(data, "quality") %>% recipes::prep() %>% recipes::juice()

# ## ---- latex_table_of_the_covariance_of_data_in_the_exploratory_data_analysis
# latex_table(round(cov(usable(data)), 2), "Covariance Matrix")

# ## ---- latex_table_of_the_correlation_of_data_in_the_exploratory_data_analysis
# latex_table(round(cor(usable(data)), 2), "Correlation Matrix")

## ---- scores_data_pairs_plot_in_the_exploratory_data_analysis
pairs_plot(scores, "quality")