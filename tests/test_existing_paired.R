# The paired differences and the guess-low PR AUC are computed inline in the
# report's `load` chunk. Run that chunk as written, then check what it built.
chunk_code <- function(label) {
  lines <- readLines("reevaluation/report.Rnw")
  start <- grep(paste0("^<<", label, "[,>]"), lines)
  stopifnot(length(start) == 1)
  end <- start + which(lines[(start + 1):length(lines)] == "@")[[1]]
  lines[(start + 1):(end - 1)]
}
load_code <- parse(text = chunk_code("load"))

run_load <- function(reader = readRDS) {
  env <- new.env(parent = globalenv())
  env$readRDS <- reader
  suppressMessages(suppressWarnings(eval(load_code, envir = env)))
  env
}

report <- run_load()
paired <- report$paired
stored <- dplyr::bind_rows(
  readRDS("results/reevaluation/metrics.rds"),
  readRDS("results/reevaluation/metrics_added.rds")
)
pr_original <- readRDS("results/reevaluation/metrics_pr_original.rds")

# Each difference is that row minus the radial SVM, no resampling, same seed.
stopifnot(nrow(paired) == 140)
ref <- stored[stored$model == "svm_radial" & stored$arm == "none", ]
ref_pr <- pr_original[pr_original$model == "svm_radial" & pr_original$arm == "none", ]
for (i in seq_len(nrow(paired))) {
  row <- paired[i, ]
  same <- ref$seed == row$seed
  stopifnot(sum(same) == 1)
  stopifnot(identical(row$d_ba, row$bal_accuracy - ref$bal_accuracy[same]))
  stopifnot(identical(row$d_roc, row$roc_auc - ref$roc_auc[same]))
  stopifnot(identical(row$d_pr, row$pr_auc - ref_pr$pr_auc[ref_pr$seed == row$seed]))
}
self <- paired[paired$model == "svm_radial" & paired$arm == "none", ]
stopifnot(nrow(self) == 5, all(self$d_ba == 0), all(self$d_roc == 0), all(self$d_pr == 0))

# Matching is by seed, not by row position: reversing the stored rows gives
# the same differences.
reversed <- run_load(function(path) {
  x <- readRDS(path)
  if (basename(path) %in% c("metrics.rds", "metrics_added.rds")) x[rev(seq_len(nrow(x))), ] else x
})
key <- function(d) d[order(d$model, d$arm, d$seed), c("model", "arm", "seed", "d_ba", "d_roc", "d_pr")]
stopifnot(identical(key(reversed$paired), key(paired)))

# The table shows the five differences in seed order, their mean, and the
# sample sd: sqrt(sum((d - mean)^2) / (5 - 1)).
table_ba <- report$paired_table("d_ba")
lr <- paired[paired$model == "lr" & paired$arm == "rose", ]
d <- lr$d_ba[order(lr$seed)]
shown <- table_ba[table_ba$Model == lr$model_name[[1]] & table_ba$Arm == "ROSE", ]
stopifnot(nrow(shown) == 1)
stopifnot(identical(unname(unlist(shown[as.character(2021:2025)])), sprintf("%+.4f", d)))
stopifnot(identical(shown$Mean, sprintf("%+.4f", sum(d) / 5)))
stopifnot(identical(shown$SD, sprintf("%.4f", sqrt(sum((d - mean(d))^2) / 4))))
stopifnot(!identical(shown$SD, sprintf("%.4f", sqrt(sum((d - mean(d))^2) / 5))))
stopifnot(nrow(report$paired_table("d_roc")) == 28, nrow(report$paired_table("d_pr")) == 28)

# Guess-low PR AUC in the report is the test share of high: 44 of 321 on
# every split, 0.137. It is not the 0.569 trapezoid of a constant score.
stopifnot(all(report$guess_high == 44), all(report$guess_n == 321))
guess <- report$by_arm[report$by_arm$model == "guess_low", ]
stopifnot(nrow(guess) == 1, isTRUE(all.equal(guess$mean_pr, 44 / 321)))
stopifnot(sprintf("%.3f", guess$mean_pr) == "0.137")
stopifnot(abs(guess$mean_pr - 0.569) > 0.4)

message("existing paired: ok")
