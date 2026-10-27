read_original_models <- function() {
  env <- new.env(parent = globalenv())
  files <- c(
    "utils/estimation/models/logistic_regression.R",
    "utils/estimation/models/support_vector_machine_with_polynomial_kernel.R",
    "utils/estimation/models/support_vector_machine_with_radial_kernel.R",
    "utils/estimation/models/linear_discriminant_analysis.R",
    "utils/estimation/models/flexible_discriminant_analysis.R"
  )
  for (file in files) {
    source(file, local = env)
  }
  list(
    lr = env$lr,
    svm_poly = env$svm_poly,
    svm_radial = env$svm_radial,
    lda = env$lda,
    fda = env$fda
  )
}

reevaluation_models <- function() {
  models <- read_original_models()
  models$lr$name <- "Logistic regression"
  models$rf <- list(
    model = parsnip::rand_forest(mtry = tune::tune(), min_n = tune::tune(), trees = 500) %>%
      parsnip::set_engine("ranger", num.threads = 1) %>%
      parsnip::set_mode("classification"),
    name = "Random forest",
    tag = "rf",
    grid = NULL
  )
  models$xgb <- list(
    model = parsnip::boost_tree(
      trees = 500,
      tree_depth = tune::tune(),
      learn_rate = tune::tune(),
      min_n = 10
    ) %>%
      parsnip::set_engine("xgboost", nthread = 1) %>%
      parsnip::set_mode("classification"),
    name = "Gradient boosting",
    tag = "xgb",
    grid = dials::grid_regular(dials::tree_depth(), dials::learn_rate(), levels = 3)
  )
  models
}

svm_tags <- c("svm_poly", "svm_radial")

with_class_weights <- function(model, weights) {
  parsnip::set_engine(model, "kernlab", class.weights = !!weights)
}

# kernlab's class-weighted probability model refits Platt scaling on
# as.factor(level names). as.factor sorts those names, so low/high comes
# back with the columns swapped relative to the decision value. The decision
# value itself stays oriented: a positive value is the second factor level.
# Correct the two columns here, before any metric is computed.
kernlab_class_weight_prob_post <- function(result, object) {
  result <- tibble::as_tibble(result)
  weights <- object$fit@kcall$class.weights
  levels <- kernlab::lev(object$fit)
  flipped <- !is.null(weights) && length(levels) == 2 && !identical(sort(levels), levels)
  if (flipped) {
    values <- as.matrix(result[, levels, drop = FALSE])
    result[[levels[[1]]]] <- values[, 2]
    result[[levels[[2]]]] <- values[, 1]
  }
  result
}

install_kernlab_class_weight_prob_fix <- function() {
  model_env <- parsnip:::get_model_env()
  for (model in c("svm_poly", "svm_rbf")) {
    key <- paste0(model, "_predict")
    pred <- model_env[[key]]
    hit <- which(
      pred$engine == "kernlab" &
        pred$mode == "classification" &
        pred$type == "prob"
    )
    if (length(hit) != 1) {
      stop("Expected one kernlab probability module for ", model)
    }
    value <- pred$value[[hit]]
    value$post <- kernlab_class_weight_prob_post
    pred$value[[hit]] <- value
    model_env[[key]] <- pred
  }
  invisible(NULL)
}

install_kernlab_class_weight_prob_fix()
