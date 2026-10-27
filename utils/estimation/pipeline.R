pipeline <- function(model_config, recipe_config, metrics, selection_metric, training_folds, train_data, data_split) {
  message(sprintf("Fitting %s / %s", model_config$tag, recipe_config$tag))

  workflow <- workflows::workflow() %>%
    workflows::add_model(model_config$model) %>%
    workflows::add_recipe(recipe_config$recipe)

  control <- tune::control_grid(save_pred = FALSE, verbose = FALSE, allow_par = FALSE)

  results <- workflow %>%
    tune::tune_grid(
      resamples = training_folds,
      grid = model_config$grid,
      metrics = metrics,
      control = control
    )

  best_result <- results %>% tune::select_best(metric = selection_metric)
  best_workflow <- workflow %>% tune::finalize_workflow(best_result)
  final_fit <- best_workflow %>% tune::last_fit(data_split)

  plot <- ggplot2::autoplot(results, metric = selection_metric)
  test_metrics <- final_fit %>% tune::collect_metrics()

  list(
    best = list(workflow = best_workflow, result = best_result),
    plot = plot,
    test = list(metrics = test_metrics),
    model_config = model_config,
    recipe_config = recipe_config
  )
}
