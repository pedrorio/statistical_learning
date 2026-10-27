# Acceptance for fix-failed-fit-recording: an unsupported weight arm comes back
# as one recorded row, not an error.
source("libraries.R")
source("reevaluation/step_winsorise.R")
source("reevaluation/metrics.R")
source("reevaluation/recipes.R")
source("reevaluation/models.R")
source("reevaluation/fit_reevaluation.R")

row <- empty_metrics(list(tag = "lgb", name = "LightGBM"), "weights", 2021L, "unsupported", "probe")
stopifnot(nrow(row) == 1, identical(row$model, "lgb"), identical(row$model_name, "LightGBM"))
stopifnot(identical(row$status, "unsupported"), identical(row$detail, "probe"), is.na(row$bal_accuracy))

job <- list(
  model = reevaluation_models()$lgb, arm = "weights", seed = 2021L,
  weights_supported = FALSE, path = tempfile(fileext = ".rds")
)
recorded <- fit_job(job, c(a = "1"), 2, 1)
stopifnot(identical(recorded$status, "unsupported"), identical(recorded$model, "lgb"))
stopifnot(identical(readRDS(job$path)$metrics, recorded))
message("failed fit recording: ok")
