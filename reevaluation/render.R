render_reevaluation <- function() {
  graded <- unname(tools::md5sum("main.pdf"))
  dir.create("build/figures", recursive = TRUE, showWarnings = FALSE)
  knitr::knit("reevaluation/report.Rnw", output = "build/reevaluation.tex")
  tex <- readLines("build/reevaluation.tex")
  tex <- gsub("build/figures/", "figures/", tex, fixed = TRUE)
  writeLines(tex, "build/reevaluation.tex")
  status <- system2("latexmk", c(
    "-pdf",
    "-interaction=nonstopmode",
    "-halt-on-error",
    "-outdir=build",
    "build/reevaluation.tex"
  ))
  if (!identical(status, 0L)) {
    stop("latexmk failed")
  }
  after <- unname(tools::md5sum("main.pdf"))
  if (!identical(graded, after)) {
    stop("build changed the graded main.pdf")
  }
  "build/reevaluation.pdf"
}
