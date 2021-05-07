# promote an element in drive_resource into a top-level column
# if new, it will be the second column, presumably after `name`
# if a column by that name already exists, it is overwritten in place
# if you request `this_var`, we look for `thisVar` in drive_resource
# but use `this_var` as the variable name
#
# morally, this is a lot like tidyr::hoist()
promote <- function(d, elem) {
  elem_orig <- elem
  elem <- camelCase(elem)
  present <- any(purrr::map_lgl(d$drive_resource, ~elem %in% names(.x)))
  if (present) {
    val <- purrr::simplify(purrr::map(d$drive_resource, elem))
    ## TO DO: find a way to emulate .default behavior from type-specific
    ## mappers ... might need to create my own simplify()
    ## https://github.com/tidyverse/purrr/issues/336
    ## as this stands, you will get a list-column whenever there is at
    ## least one NULL
  } else {
    ## TO DO: do we really want promote() to be this forgiving?
    ## adds a placeholder column for elem if not present in drive_resource
    ## ensure elem is added, even if there are zero rows
    val <- rep_len(list(NULL), nrow(d))
  }
  put_column(d, nm = elem_orig, val = val, .after = 1)
}
