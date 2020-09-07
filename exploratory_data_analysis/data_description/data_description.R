## ---- setup_in_data_description
invisible(source('../../libraries.R', chdir = TRUE))

## ---- load_raw_data_in_data_description
data <- load_raw_data("../../data/winequality-red.csv")

## ---- count_plots_of_raw_and_recoded_quality_factors_in_data_description
count_plot(data, "quality", c("3","4","5","6","7","8"))
data <- load_recoded_data("../../data/winequality-red.csv", "quality")
count_plot(data, "quality", c("low", "high"))


# ---- latex_table_of_data_description_in_data_description
# latex_table(psych::describe(data), "Data description")
latex_table(skim_with(numeric = sfl(hist = NULL))(data) %>% yank("numeric"), "Numeric variables", latex_options = c("hold_position"))
# latex_table(skim_with(numeric = sfl(hist = NULL))(data) %>% yank("factor"), "Factor variables", latex_options = c("hold_position"))
# latex_table(skim_with(numeric = sfl(hist = NULL))(data %>% group_by(quality)) %>% yank("numeric"), "Numeric variables", latex_options = c("hold_position"))
# latex_table(skim_with(numeric = sfl(hist = NULL))(data %>% group_by(quality)) %>% yank("factor"), "Factor variables", latex_options = c("hold_position"))
# latex_table(psych::describeBy(data, group = data[["quality"]])$high, "Data Description (high quality)")
# latex_table(psych::describeBy(data, group = data[["quality"]])$low, "Data description (low quality)")

## ---- correlation_plot_of_data_in_data_description
GGally::ggcorr(usable(data),  hjust = 0.75, label = TRUE, layout.exp = 1)

## ---- data_pairs_plot_in_data_description
pairs_plot(data, "quality")

## ---- boxplots_of_quality_in_comparison_with_other_variables_in_data_description
box_plot(data, "quality", "alcohol")
box_plot(data, "quality", "sulphates")
box_plot(data, "quality", "density")
box_plot(data, "quality", "fixed.acidity")
box_plot(data, "quality", "volatile.acidity")
# box_plot(data, "quality", "chlorides")
# box_plot(data, "quality", "residual.sugar")
# box_plot(data, "quality", "citric.acid")
# box_plot(data, "quality", "pH")
# box_plot(data, "quality", "free.sulfur.dioxide")
# box_plot(data, "quality", "total.sulfur.dioxide")

## ---- plots_of_alcohol_per_quality_class_in_data_description
density_plot(data, "quality", "alcohol")
box_plot(data, "quality", "alcohol")

## ---- plots_of_sulphates_per_quality_class_in_data_description
density_plot(data, "quality", "sulphates")
box_plot(data, "quality", "sulphates")

## ---- plots_of_density_per_quality_class_in_data_description
density_plot(data, "quality", "density")
box_plot(data, "quality", "density")

## ---- plots_of_fixed_acidity_per_quality_class_in_data_description
density_plot(data, "quality", "fixed.acidity")
box_plot(data, "quality", "fixed.acidity")

## ---- plots_of_volatile_acidity_per_quality_class_in_data_description
density_plot(data, "quality", "volatile.acidity")
box_plot(data, "quality", "volatile.acidity")