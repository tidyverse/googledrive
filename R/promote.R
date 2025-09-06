# promote an element in drive_resource into a top-level column
#
# if you request `this_var` or `thisVar`, we look for `thisVar` in
# drive_resource, but use the original input as the variable name
#
# if a column by that name already exists, it is overwritten in place
# otherwise, the new column will be the second column, presumably after `name`
#
# morally, this is a lot like tidyr::hoist(), but with a more specific mandate
promote <- function(d, elem) {
  elemCamelCase <- camelCase(elem)

  x <- map(d$drive_resource, elemCamelCase)
  absent <- all(map_lgl(x, is_null))

  if (absent) {
    # TO DO: do we really want promote() to be this forgiving?
    # adds a placeholder column for elem if not present in drive_resource
    # ensure elem is added, even if there are zero rows
    val <- rep_len(list(NULL), nrow(d))
  } else {
    val <- simplify_col(x)
  }

  put_column(d, nm = elem, val = val, .after = 1)
}

# simplified version of tidyr:::simplify_col()
simplify_col <- function(x) {
  is_list <- map_lgl(x, is_list)
  is_vec <- map_lgl(x, ~ vec_is(.x) || is_null(.x))
  is_not_vec <- !is_vec
  if (any(is_list | is_not_vec)) {
    return(x)
  }

  n <- map_int(x, vec_size)
  is_scalar <- n %in% c(0, 1)
  if (any(!is_scalar)) {
    return(x)
  }

  x[n == 0] <- list(NA)

  tryCatch(
    vec_c(!!!x),
    vctrs_error_incompatible_type = function(e) x
  )
}
