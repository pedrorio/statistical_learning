## ---- setup_in_outlier_detection
invisible(source("../../libraries.R", chdir = TRUE))

## ---- load_recoded_data_in_outlier_detection
data <- load_recoded_data("../../data/winequality-red.csv", "quality")

## ---- outlier_detection_plot_before_winsorisation_in_outlier_detection
outlier_detection_plot(data, "quality")

## ---- outliers_winsorisation_per_quality_class_in_outlier_detection
recoded_winsorised_data <-
  recipes::recipe(quality ~ ., data = data) %>% 
  step_winsorise(recipes::all_numeric()) %>%
  recipes::prep() %>%
  recipes::juice()

## ---- outlier_detection_plot_after_winsorisation_in_outlier_detection
outlier_detection_plot(recoded_winsorised_data, "quality")