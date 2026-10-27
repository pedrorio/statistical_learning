source_files <- c(
  "reevaluation/step_winsorise.R",
  "reevaluation/metrics.R",
  "reevaluation/recipes.R",
  "reevaluation/models.R",
  "reevaluation/fit_reevaluation.R",
  "data/winequality-red.csv",
  "renv.lock"
)

file_md5 <- function(path) {
  sum <- tools::md5sum(path)
  if (is.na(sum[[1]])) {
    stop("Cannot hash ", path)
  }
  unname(sum[[1]])
}

make_case_weights <- function(train) {
  n <- nrow(train)
  n_high <- sum(train$quality == "high")
  n_low <- sum(train$quality == "low")
  weights <- ifelse(train$quality == "high", n / (2 * n_high), n / (2 * n_low))
  hardhat::importance_weights(weights)
}

class_weight_vector <- function(train) {
  n <- nrow(train)
  n_high <- sum(train$quality == "high")
  n_low <- sum(train$quality == "low")
  c(low = unname(n / (2 * n_low)), high = unname(n / (2 * n_high)))
}

predictor_count <- function(recipe, data) {
  baked <- recipes::bake(recipes::prep(recipe, training = data), new_data = NULL)
  sum(!names(baked) %in% c("quality", "case_weight"))
}

rf_grid <- function(n_predictors) {
  dials::grid_regular(
    dials::mtry(c(1L, as.integer(n_predictors))),
    dials::min_n(),
    levels = 3
  )
}

params_text <- function(params) {
  if (is.null(params) || !is.data.frame(params) || nrow(params) != 1) {
    return(NA_character_)
  }
  keep <- setdiff(names(params), ".config")
  if (length(keep) == 0) {
    return(NA_character_)
  }
  pieces <- vapply(keep, function(name) {
    value <- params[[name]][[1]]
    if (is.numeric(value)) {
      value <- signif(value, 4)
    }
    paste0(name, "=", value)
  }, character(1))
  paste(pieces, collapse = ", ")
}

empty_metrics <- function(model, arm, seed, status, detail) {
  tibble::tibble(
    model = model$tag,
    model_name = model$name,
    arm = arm,
    seed = seed,
    status = status,
    bal_accuracy = NA_real_,
    roc_auc = NA_real_,
    accuracy = NA_real_,
    tp = NA_real_,
    fp = NA_real_,
    tn = NA_real_,
    fn = NA_real_,
    threshold = NA_real_,
    n_test = NA_integer_,
    detail = detail,
    params = NA_character_
  )
}

job_key <- function(job, source_md5, v, repeats) {
  list(
    seed = job$seed,
    arm = job$arm,
    model = job$model$tag,
    rng = "L'Ecuyer-CMRG",
    split_prop = 0.8,
    split_strata = TRUE,
    v = as.integer(v),
    repeats = as.integer(repeats),
    fold_strata = "quality",
    metric = "bal_accuracy",
    event = "high",
    sources = source_md5
  )
}

fit_job <- function(job, source_md5, v, repeats) {
  key <- job_key(job, source_md5, v, repeats)
  if (file.exists(job$path)) {
    loaded <- tryCatch(readRDS(job$path), error = function(e) NULL)
    if (is.list(loaded) && identical(loaded$key, key)) {
      message(sprintf("Cached %s / %s / %d", job$model$tag, job$arm, job$seed))
      return(loaded$metrics)
    }
  }

  message(sprintf("Fitting %s / %s / %d", job$model$tag, job$arm, job$seed))
  metrics <- tryCatch(
    score_job(job),
    error = function(e) {
      message(sprintf(
        "No test score for %s / %s / %d: %s",
        job$model$tag, job$arm, job$seed, conditionMessage(e)
      ))
      empty_metrics(job$model, job$arm, job$seed, "na", conditionMessage(e))
    }
  )

  tmp <- paste0(job$path, ".tmp.", Sys.getpid())
  saveRDS(list(key = key, metrics = metrics), tmp)
  file.rename(tmp, job$path)
  metrics
}

score_job <- function(job) {
  model <- job$model$model
  if (job$arm == "weights" && job$model$tag %in% svm_tags) {
    model <- with_class_weights(model, job$class_weights)
  }
  recipe <- filtered_recipe(job$train, job$arm)
  workflow <- workflows::workflow() %>%
    workflows::add_model(model) %>%
    workflows::add_recipe(recipe)
  if (job$arm == "weights" && !(job$model$tag %in% svm_tags)) {
    workflow <- workflows::add_case_weights(workflow, case_weight)
  }

  grid <- job$model$grid
  if (job$model$tag == "rf") {
    grid <- rf_grid(predictor_count(recipe, job$train))
  }

  selection <- yardstick::metric_set(yardstick::bal_accuracy)
  tuned <- tune::tune_grid(
    workflow,
    resamples = job$folds,
    grid = grid,
    metrics = selection,
    control = tune::control_grid(
      save_pred = FALSE,
      verbose = FALSE,
      allow_par = FALSE,
      event_level = "second"
    )
  )
  best <- tune::select_best(tuned, metric = "bal_accuracy")
  final_workflow <- tune::finalize_workflow(workflow, best)
  resampled <- tune::fit_resamples(
    final_workflow,
    resamples = job$folds,
    metrics = yardstick::metric_set(yardstick::bal_accuracy, yardstick::roc_auc),
    control = tune::control_resamples(
      save_pred = TRUE,
      verbose = FALSE,
      allow_par = FALSE,
      event_level = "second"
    )
  )
  oof <- tune::collect_predictions(resampled)
  if (!".pred_high" %in% names(oof)) {
    stop("The selected workflow produced no P(high)")
  }
  threshold <- choose_threshold(oof$quality, oof$.pred_high)

  fitted <- generics::fit(final_workflow, data = job$train)
  test_prob <- predict(fitted, job$test, type = "prob")
  scored <- score_at_threshold(job$test$quality, test_prob$.pred_high, threshold)
  if (!is.finite(scored$bal_accuracy)) {
    stop("The final fit produced no predictions")
  }

  tibble::tibble(
    model = job$model$tag,
    model_name = job$model$name,
    arm = job$arm,
    seed = job$seed,
    status = "ok",
    bal_accuracy = scored$bal_accuracy,
    roc_auc = scored$roc_auc,
    accuracy = scored$accuracy,
    tp = scored$tp,
    fp = scored$fp,
    tn = scored$tn,
    fn = scored$fn,
    threshold = scored$threshold,
    n_test = nrow(job$test),
    detail = NA_character_,
    params = params_text(best)
  )
}

make_outer_splits <- function(data, seeds, v, repeats) {
  RNGkind("L'Ecuyer-CMRG")
  lapply(seeds, function(seed) {
    set.seed(seed)
    split <- rsample::initial_split(data, prop = 0.8, strata = quality)
    train <- rsample::training(split)
    test <- rsample::testing(split)
    plain_folds <- rsample::vfold_cv(train, v = v, repeats = repeats, strata = quality)
    weighted_train <- train
    weighted_train$case_weight <- make_case_weights(train)
    weighted_test <- test
    weighted_test$case_weight <- hardhat::importance_weights(rep(1, nrow(test)))
    weighted_folds <- rsample::vfold_cv(
      weighted_train, v = v, repeats = repeats, strata = quality
    )
    list(
      seed = seed,
      train = train,
      test = test,
      folds = plain_folds,
      weighted_train = weighted_train,
      weighted_test = weighted_test,
      weighted_folds = weighted_folds,
      class_weights = class_weight_vector(train)
    )
  })
}

fit_reevaluation <- function(
  fits_dir = "results/reevaluation",
  seeds = 2021:2025,
  v = 10L,
  repeats = 10L,
  model_tags = NULL,
  arms = c("rose", "weights", "none")
) {
  dir.create(fits_dir, recursive = TRUE, showWarnings = FALSE)
  Sys.setenv(OMP_NUM_THREADS = "1")
  cores <- parallel::detectCores(logical = TRUE)
  if (is.na(cores) || cores < 1) {
    cores <- 1L
  }
  cores <- as.integer(cores)

  data <- load_recoded_data("data/winequality-red.csv", "quality")
  outers <- make_outer_splits(data, seeds, v, repeats)
  models <- reevaluation_models()
  if (is.null(model_tags)) {
    model_tags <- names(models)
  }
  source_md5 <- vapply(source_files, file_md5, character(1))

  jobs <- list()
  for (outer in outers) {
    for (arm in arms) {
      for (tag in model_tags) {
        model <- models[[tag]]
        file <- sprintf("%s__%s__%s.rds", tag, arm, outer$seed)
        use_case_weights <- arm == "weights" && !(tag %in% svm_tags)
        jobs[[length(jobs) + 1]] <- list(
          model = model,
          arm = arm,
          seed = outer$seed,
          train = if (use_case_weights) outer$weighted_train else outer$train,
          test = if (use_case_weights) outer$weighted_test else outer$test,
          folds = if (use_case_weights) outer$weighted_folds else outer$folds,
          class_weights = outer$class_weights,
          path = file.path(fits_dir, file)
        )
      }
    }
  }

  baseline <- dplyr::bind_rows(lapply(outers, function(outer) {
    scored <- guess_low_metrics(outer$test$quality)
    tibble::tibble(
      model = "guess_low",
      model_name = "Guess low",
      arm = "baseline",
      seed = outer$seed,
      status = "ok",
      bal_accuracy = scored$bal_accuracy,
      roc_auc = scored$roc_auc,
      accuracy = scored$accuracy,
      tp = scored$tp,
      fp = scored$fp,
      tn = scored$tn,
      fn = scored$fn,
      threshold = scored$threshold,
      n_test = nrow(outer$test),
      detail = NA_character_,
      params = NA_character_
    )
  }))
  saveRDS(baseline, file.path(fits_dir, "baseline.rds"))

  message(sprintf(
    "Fitting %d combinations on %d cores, seeds %s, %d x %d CV",
    length(jobs), cores, paste(seeds, collapse = ","), v, repeats
  ))
  started <- proc.time()[["elapsed"]]
  out <- parallel::mclapply(
    jobs,
    fit_job,
    source_md5 = source_md5,
    v = v,
    repeats = repeats,
    mc.cores = cores,
    mc.preschedule = FALSE,
    mc.set.seed = TRUE
  )
  failed <- vapply(out, inherits, logical(1), what = "try-error")
  if (any(failed)) {
    stop(paste(vapply(out[failed], as.character, character(1)), collapse = "\n"))
  }

  metrics <- dplyr::bind_rows(out)
  saveRDS(metrics, file.path(fits_dir, "metrics.rds"))
  wall_seconds <- proc.time()[["elapsed"]] - started
  run <- list(
    cores = cores,
    wall_seconds = wall_seconds,
    seeds = seeds,
    v = as.integer(v),
    repeats = as.integer(repeats),
    combinations = length(jobs)
  )
  saveRDS(run, file.path(fits_dir, "run.rds"))
  message(sprintf("Fit finished in %.1f seconds on %d cores", wall_seconds, cores))
  run
}
