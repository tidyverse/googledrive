dribble_maybe_reconstruct <- function(data, template) {
  if (dribble_is_reconstructable(data)) {
    # in workflowsets, davis uses new_workflow_set0(x) here
    new_dribble(data)
  } else {
    # davis says:
    # in dribble_maybe_reconstruct(), rather than as_tibble() you may want to
    # use new_tibble(). I think there is a chance that the input could actually
    # just be a list, rather than a data frame, so really you are just adding
    # the appropriate data frame specific attributes back on the list.
    #
    # Therefore, I've taken new_tibble0() from what he does in workflowsets
    new_tibble0(data)
  }
}

dribble_is_reconstructable <- function(data) {
  # continuing davis's comments from above:
  # ... that might also mean you should remove the is.data.frame() check that is
  # there, and instead just check the structure of the object (col names, types,
  # etc).
  #
  # in workflowsets, he uses has_required_container_type(),
  # which is just rlang::is_list()
  is.data.frame(data) &&
    has_dribble_cols(data) &&
    has_dribble_coltypes(data) &&
    has_drive_resource(data)

  # TODO: I suspect I should not accept NAs in the id column
  # maybe also name?
}

new_tibble0 <- function(x, ..., class = NULL) {
   # Handle the 0-row case correctly by using `new_data_frame()`.
   # This also correctly strips any attributes except `names` off `x`.
   x <- vctrs::new_data_frame(x)
   tibble::new_tibble(x, nrow = nrow(x), class = class)
}
