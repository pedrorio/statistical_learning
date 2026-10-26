source("libraries.R")
source("utils/estimation/fit_combinations.R")

timing <- fit_combinations()
message(sprintf("cores=%d wall_seconds=%.1f combinations=%d", timing$cores, timing$seconds, timing$n))
