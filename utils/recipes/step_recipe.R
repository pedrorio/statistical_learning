step_winsorise_new <- function(
  terms   = NULL,
  role    = NA,
  skip    = FALSE,
  trained = FALSE,
  predictor_column_names = NULL,
  outcome_column_name = NULL,
  id = NULL
  ) {
  recipes::step("winsorise", 
    terms = terms,
    role = role,
    skip = skip,
    trained = trained,
    predictor_column_names = predictor_column_names,
    outcome_column_name = outcome_column_name,
    id = id
  )
}

step_winsorise <- function(
  recipe, 
  ..., 
  role    = NA,
  skip    = FALSE,
  trained = FALSE,
  predictor_column_names = NULL,
  outcome_column_name = NULL,
  id = recipes::rand_id("winsorise")
  ) {
  recipes::add_step(
    recipe, 
    step_winsorise_new(
      terms = recipes::ellipse_check(...), 
      role    = role,
      skip    = skip,
      trained = trained,
      predictor_column_names = predictor_column_names,
      outcome_column_name = outcome_column_name,
      id = id
    )
  )
}

prep.step_winsorise <- function(x, training, info = NULL, ...) {
  predictor_col_names <- recipes::terms_select(info = info, x$terms)
  outcome_col_names <- recipes::terms_select(info = info, recipes::all_outcomes())
  outcome_col_name <- outcome_col_names[1]

    step_winsorise_new(
      terms   = x$terms,
      role    = x$role,
      skip    = x$skip,
      trained = TRUE,
      predictor_column_names = predictor_col_names,
      outcome_column_name = outcome_col_name,
      id = x$id
    )
}

bake.step_winsorise <- function(object, new_data, info = NULL, ...) {
  outcome_classes <- sort(unique(new_data[[object$outcome_column_name]]))
  column_names <- colnames(new_data %>% dplyr::select(!where(is.factor)))
  new_data <- old_data <- as.data.frame(new_data)

  for (i in outcome_classes) {
    selection <- new_data[[object$outcome_column_name]] == i
     new_data[selection, column_names] <- 
      robustHD::winsorize(
        old_data[selection, column_names], 
        standardized = FALSE, 
        centerFun = median, 
        prob = 0.999
      )
  }
  new_data %>% tibble()
}

print.step_winsorise <- function(x, width = max(20, options()$width - 30), ...) {
  cat("Winsorising ", sep = "")
  printer(untr_obj = x$terms, tr_obj = x$predictor_column_names, trained = x$trained, width = width)
  invisible(x)
}
