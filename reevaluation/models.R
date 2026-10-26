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
