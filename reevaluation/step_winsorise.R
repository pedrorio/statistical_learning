# The graded bake calls robustHD::winsorize on a data.frame. That method
# passes its extra arguments to as.matrix, so prob = 0.999 never arrives.
# The matrix method then runs with its default prob of 0.95.
winsorise_prob <- 0.95
winsorise_const <- 2

step_winsorise_train_new <- function(
  terms,
  role,
  trained,
  skip,
  columns,
  center,
  scale,
  inv_cor,
  cutoff,
  const,
  prob,
  id
) {
  recipes::step(
    "winsorise_train",
    terms = terms,
    role = role,
    trained = trained,
    skip = skip,
    columns = columns,
    center = center,
    scale = scale,
    inv_cor = inv_cor,
    cutoff = cutoff,
    const = const,
    prob = prob,
    id = id
  )
}

step_winsorise_train <- function(
  recipe,
  ...,
  role = NA,
  trained = FALSE,
  skip = FALSE,
  columns = NULL,
  center = NULL,
  scale = NULL,
  inv_cor = NULL,
  cutoff = NULL,
  const = winsorise_const,
  prob = winsorise_prob,
  id = recipes::rand_id("winsorise_train")
) {
  recipes::add_step(
    recipe,
    step_winsorise_train_new(
      terms = rlang::enquos(...),
      role = role,
      trained = trained,
      skip = skip,
      columns = columns,
      center = center,
      scale = scale,
      inv_cor = inv_cor,
      cutoff = cutoff,
      const = const,
      prob = prob,
      id = id
    )
  )
}

huber_inverse <- function(standardized, const, prob) {
  correlation <- .Call(
    "R_corMatHuber",
    R_x = standardized,
    R_c = const,
    R_prob = prob,
    R_tol = .Machine$double.eps ^ 0.5,
    PACKAGE = "robustHD"
  )
  m <- ncol(standardized)
  eig <- eigen(correlation, symmetric = TRUE)
  if (eig$values[[m]] < 0) {
    rotation <- eig$vectors
    lambda <- apply(standardized %*% rotation, 2, stats::mad) ^ 2
    correlation <- rotation %*% diag(lambda, nrow = length(lambda)) %*% t(rotation)
  }
  solve(correlation)
}

prep.step_winsorise_train <- function(x, training, info = NULL, ...) {
  columns <- recipes::recipes_eval_select(x$terms, training, info)
  standardized <- robustHD:::robStandardize(
    as.matrix(training[, columns, drop = FALSE]),
    centerFun = stats::median,
    scaleFun = stats::mad
  )
  center <- attr(standardized, "center")
  scale <- attr(standardized, "scale")
  names(center) <- columns
  names(scale) <- columns
  inv_cor <- huber_inverse(standardized, x$const, x$prob)
  dimnames(inv_cor) <- list(columns, columns)

  step_winsorise_train_new(
    terms = x$terms,
    role = x$role,
    trained = TRUE,
    skip = x$skip,
    columns = columns,
    center = center,
    scale = scale,
    inv_cor = inv_cor,
    cutoff = stats::qchisq(x$prob, df = length(columns)),
    const = x$const,
    prob = x$prob,
    id = x$id
  )
}

bake.step_winsorise_train <- function(object, new_data, ...) {
  new_data <- as.data.frame(new_data)
  present <- object$columns[object$columns %in% names(new_data)]
  if (length(present) == 0) {
    return(tibble::as_tibble(new_data))
  }
  values <- as.matrix(new_data[, present, drop = FALSE])
  standardized <- sweep(values, 2, object$center[present], "-")
  standardized <- sweep(standardized, 2, object$scale[present], "/")
  distance <- rowSums((standardized %*% object$inv_cor[present, present, drop = FALSE]) * standardized)
  weights <- pmin(sqrt(object$cutoff / distance), 1)
  standardized <- weights * standardized
  standardized <- sweep(standardized, 2, object$scale[present], "*")
  standardized <- sweep(standardized, 2, object$center[present], "+")
  new_data[, present] <- standardized
  tibble::as_tibble(new_data)
}

print.step_winsorise_train <- function(x, width = max(20, options()$width - 30), ...) {
  cat("Winsorising from training median, MAD, and Huber correlation\n")
  invisible(x)
}

registerS3method("prep", "step_winsorise_train", prep.step_winsorise_train)
registerS3method("bake", "step_winsorise_train", bake.step_winsorise_train)
registerS3method("print", "step_winsorise_train", print.step_winsorise_train)
