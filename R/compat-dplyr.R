dribble_maybe_reconstruct <- function(data, template) {
  if (dribble_is_reconstructable(data)) {
    # in workflowsets, davis uses new_workflow_set0(x) here
    new_dribble(data)
  } else {
    # @davis tells me there can be internal-to-vctrs-or-dplyr situations where
    # reconstruction starts with a conformable list, instead of data.frame
    new_tibble0(data)
  }
}

dribble_is_reconstructable <- function(data) {
  # see above for why this is is_list() instead of is.data.frame()
  is_list(data) &&
    has_dribble_cols(data) &&
    has_dribble_coltypes(data) &&
    has_drive_resource(data)

}

new_tibble0 <- function(x, ..., class = NULL) {
  # Handle the 0-row case correctly by using `new_data_frame()`.
  # This also correctly strips any attributes except `names` off `x`.
  x <- vctrs::new_data_frame(x)
  tibble::new_tibble(x, nrow = nrow(x), class = class)
}
