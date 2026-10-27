read_fit_summaries <- function(dir) {
  manifest_path <- file.path(dir, "manifest.rds")
  if (!file.exists(manifest_path)) {
    stop("No fit manifest at ", manifest_path, ". Run Rscript fit.R from the repository root.")
  }
  manifest <- readRDS(manifest_path)
  lapply(manifest, function(file) {
    path <- file.path(dir, file)
    if (!file.exists(path)) {
      stop("Missing fit summary ", path, ". Run Rscript fit.R from the repository root.")
    }
    readRDS(path)$summary
  })
}
