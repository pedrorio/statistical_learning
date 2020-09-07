pipeline <- function(model_config, recipe_config, metrics, selection_metric, training_folds, train_data, data_split) {
  

    print("======================================================================================")
    print(stringr::str_interp("Starting pipeline for ${model_config$tag} and ${recipe_config$tag}"))
    print("======================================================================================")

    # create the workflow
    workflow <- workflows::workflow() %>% workflows::add_model(model_config$model) %>% workflows::add_recipe(recipe_config$recipe)
    print("After workflow")
    # control grid
    # packages <- c(classification_and_discrimination_packages, local_packages, c("tidymodels"))
    # packages <- c(classification_and_discrimination_packages, c("tidymodels"))
    # print(packages)
    # control <- tune::control_grid(save_pred = TRUE, verbose = TRUE, allow_par = FALSE, pkgs = packages)
    control <- tune::control_grid(save_pred = TRUE, verbose = TRUE)
    print("After control")
    # compute the metrics across the param grid and folds
    results <- workflow %>% 
        tune::tune_grid(
            resamples = training_folds, 
            grid = model_config$grid, 
            metrics = metrics, 
            control = control
            )
    print("After results")
    # choose the params with the best metric
    best_result <- results %>% tune::select_best(selection_metric)
    print("After best results")
    # update the params in the workflow
    best_workflow <- workflow %>% tune::finalize_workflow(best_result)
    print("After best workflow")
    # compute the metric across the test set
    final_fit <- best_workflow %>% tune::last_fit(data_split)
    print("After final fit")

    train_metrics <- results %>% collect_metrics()
    print("After train metrics")
    train_predictions <- results %>% collect_predictions()
    print("After train predictions")
    train_confusion_matrix <- train_predictions %>% conf_mat(truth = quality, estimate = .pred_class)
    print("After train confusion matrix")
    train <- list(metrics = train_metrics, predictions = train_predictions, confusion_matrix = train_confusion_matrix)

    plot <- autoplot(results, metric=selection_metric)
    print("After plot")

    test_metrics <- final_fit %>% collect_metrics()
    print("After test metrics")
    test_predictions <- final_fit %>% collect_predictions()
    print("After test predictions")
    test_confusion_matrix <- test_predictions %>% conf_mat(truth = quality, estimate = .pred_class)
    print("After test confusion matrix")

    test <- list(metrics = test_metrics, predictions = test_predictions, confusion_matrix = test_confusion_matrix)

    best <- list(workflow = best_workflow, result = best_result)

    final <- final_fit
    
    # return the results
    return(
      list(
        workflow=workflow, 
        results=results,
        best = best,
        final = final,
        plot=plot,
        train=train,
        test=test,
        model_config=model_config,
        recipe_config=recipe_config
      )
    )
}