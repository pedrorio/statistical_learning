filtered_recipe <- function(train_data, arm) {
  if (!arm %in% c("rose", "weights", "none")) {
    stop("Unknown arm ", arm)
  }
  recipe <- recipes::recipe(quality ~ ., data = train_data) %>%
    recipes::step_naomit(recipes::all_numeric()) %>%
    recipes::step_zv(recipes::all_predictors())
  if (arm == "rose") {
    recipe <- recipe %>% themis::step_rose(recipes::all_outcomes())
  }
  recipe %>%
    recipes::step_nzv(recipes::all_predictors()) %>%
    recipes::step_corr(threshold = 0.80, recipes::all_numeric()) %>%
    recipes::step_lincomb(recipes::all_numeric()) %>%
    step_winsorise_train(recipes::all_numeric())
}

# Same filters as filtered_recipe() with arm "none". The outcome stays the
# integer score, so the numeric selectors have to be predictors: all_numeric()
# would winsorise the score itself.
score_recipe <- function(train_data) {
  recipes::recipe(quality ~ ., data = train_data) %>%
    recipes::step_naomit(recipes::all_predictors()) %>%
    recipes::step_zv(recipes::all_predictors()) %>%
    recipes::step_nzv(recipes::all_predictors()) %>%
    recipes::step_corr(threshold = 0.80, recipes::all_numeric_predictors()) %>%
    recipes::step_lincomb(recipes::all_numeric_predictors()) %>%
    step_winsorise_train(recipes::all_numeric_predictors())
}
