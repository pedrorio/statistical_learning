source("./helpers/index.R", chdir = TRUE)

library(ggplot2, warn.conflicts = FALSE)
library(GGally, warn.conflicts = FALSE)
library(knitr, warn.conflicts = FALSE)
library(kableExtra, warn.conflicts = FALSE)
library(forcats, warn.conflicts = FALSE)
library(psych, warn.conflicts = FALSE)
library(skimr, warn.conflicts = FALSE)
library(tidytext, warn.conflicts = FALSE)
library(cluster, warn.conflicts = FALSE)
library(rrcov, warn.conflicts = FALSE)
library(stringr, warn.conflicts = FALSE)
library(robustHD, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)
library(purrr, warn.conflicts = FALSE)
library(tidyverse, warn.conflicts = FALSE)
library(tidymodels, warn.conflicts = FALSE)
library(recipes, warn.conflicts = FALSE)
library(parsnip, warn.conflicts = FALSE)
library(workflows, warn.conflicts = FALSE)
library(parallel, warn.conflicts = FALSE)
library(doFuture, warn.conflicts = FALSE)
library(rsample, warn.conflicts = FALSE)
library(discrim, warn.conflicts = FALSE)
library(tune, warn.conflicts = FALSE)
library(yardstick, warn.conflicts = FALSE)
library(glmnet, warn.conflicts = FALSE)
library(Matrix, warn.conflicts = FALSE)
library(mda, warn.conflicts = FALSE)
library(klaR, warn.conflicts = FALSE)
library(earth, warn.conflicts = FALSE)
library(kernlab, warn.conflicts = FALSE)
library(future, warn.conflicts = FALSE)
library(furrr, warn.conflicts = FALSE)
library(themis, warn.conflicts = FALSE)

declared <- unique(c(
  data_description_packages,
  exploratory_data_analysis_packages,
  outlier_detection_packages,
  data_reduction_packages,
  classification_and_discrimination_packages,
  clustering_packages
))
attached <- c(
  "ggplot2", "GGally", "knitr", "kableExtra", "forcats",
  "psych", "skimr", "tidytext", "cluster", "rrcov", "stringr", "robustHD",
  "dplyr", "purrr", "tidyverse", "tidymodels", "recipes", "parsnip",
  "workflows", "parallel", "doFuture", "rsample", "discrim", "tune",
  "yardstick", "glmnet", "Matrix", "mda", "klaR", "earth", "kernlab",
  "future", "furrr", "themis"
)
if (!setequal(declared, attached)) {
  stop("packages/load.R does not match packages/helpers/list.R")
}
