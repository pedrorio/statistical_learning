source("libraries.R")

raw <- data.frame(
  quality = factor(rep(c("low", "high"), each = 200)),
  x = rnorm(400),
  y = rnorm(400)
)
raw$x[raw$quality == "low"][1] <- 1e6
raw$y[raw$quality == "high"][1] <- -1e6

recipe <- recipes::recipe(quality ~ ., data = raw) %>%
  step_winsorise(recipes::all_numeric())
prepped <- recipes::prep(recipe)
baked <- recipes::bake(prepped, raw)

stopifnot(identical(baked$quality, raw$quality))

expected <- raw
for (level in levels(raw$quality)) {
  rows <- raw$quality == level
  expected[rows, c("x", "y")] <- robustHD::winsorize(
    raw[rows, c("x", "y")],
    standardized = FALSE,
    centerFun = median,
    prob = 0.999
  )
}
stopifnot(isTRUE(all.equal(baked$x, expected$x, tolerance = 1e-8)))
stopifnot(isTRUE(all.equal(baked$y, expected$y, tolerance = 1e-8)))
stopifnot(!grepl("terms_select", paste(deparse(prep.step_winsorise), collapse = "\n")))

message("winsorise ok")
