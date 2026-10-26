source("libraries.R")
source("reevaluation/step_winsorise.R")

set.seed(1)
raw <- data.frame(
  quality = factor(rep(c("low", "high"), each = 200), levels = c("low", "high")),
  x = rnorm(400),
  y = rnorm(400)
)
raw$x[1] <- 1e6
raw$y[201] <- -1e6

recipe <- recipes::recipe(quality ~ ., data = raw) %>%
  step_winsorise_train(recipes::all_numeric())
prepped <- recipes::prep(recipe)
step <- prepped$steps[[1]]

center_x <- median(raw$x)
scale_x <- stats::mad(raw$x - center_x, center = 0)
stopifnot(isTRUE(all.equal(unname(step$center[["x"]]), center_x)))
stopifnot(isTRUE(all.equal(unname(step$scale[["x"]]), scale_x)))
stopifnot(identical(unname(step$prob), 0.95))
stopifnot(identical(unname(step$const), 2))
stopifnot(!("quality" %in% step$columns))

baked <- recipes::bake(prepped, raw)
expected <- robustHD::winsorize(
  raw[, c("x", "y")],
  standardized = FALSE,
  centerFun = median,
  prob = 0.999
)
stopifnot(isTRUE(all.equal(baked$x, expected[, "x"], tolerance = 1e-8)))
stopifnot(isTRUE(all.equal(baked$y, expected[, "y"], tolerance = 1e-8)))

permuted <- raw
permuted$quality <- sample(permuted$quality)
baked_permuted <- recipes::bake(prepped, permuted)
stopifnot(isTRUE(all.equal(baked_permuted$x, baked$x)))
stopifnot(isTRUE(all.equal(baked_permuted$y, baked$y)))

removed <- raw[, c("x", "y")]
baked_removed <- recipes::bake(prepped, removed)
stopifnot(isTRUE(all.equal(baked_removed$x, baked$x)))
stopifnot(isTRUE(all.equal(baked_removed$y, baked$y)))

fresh <- raw
fresh$x <- rnorm(400)
fresh$x[1] <- 1e5
refit <- robustHD::winsorize(
  fresh[, c("x", "y")],
  standardized = FALSE,
  centerFun = median,
  prob = 0.999
)
baked_fresh <- recipes::bake(prepped, fresh)
stopifnot(!isTRUE(all.equal(baked_fresh$x, refit[, "x"], tolerance = 1e-6)))

message("reevaluation winsorise ok")
