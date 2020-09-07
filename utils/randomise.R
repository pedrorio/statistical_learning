randomise <- function(dataset) {
  return(
    dataset %>% 
      dplyr::select(!where(is.factor)) %>%
      purrr::map(~runif(length(.), min(.), max(.)))
      # furrr::future_map(~runif(length(.), min(.), max(.)))
  )
}