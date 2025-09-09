# based on https://github.com/tidymodels/workflowsets/blob/main/R/compat-vctrs.R

# ------------------------------------------------------------------------------

# `vec_restore()`
#
# Called at the end of `vec_slice()` and `vec_ptype()` after all slicing has
# been done on the proxy object.

#' @export
vec_restore.dribble <- function(x, to, ...) {
  dribble_maybe_reconstruct(x)
}

# ------------------------------------------------------------------------------

# `vec_ptype2()`
#
# When combining two dribbles together, `x` and `y` will be zero-row slices
# which should always result in a new dribble, as long as
# `df_ptype2()` can compute a common type.
#
# Combining a dribble with a tibble/data.frame will only ever happen if
# the user calls `vec_c()` or `vec_rbind()` with one of each of those inputs.
# Although I could probably make this work, it feels pretty weird and exotic
# and I think that user, if they even exist, should just turn that "other"
# tibble/data.frame into a dribble first.
# So I'll follow workflowsets and not attempt to return dribble for these
# combinations.

#' @export
vec_ptype2.dribble.dribble <- function(x, y, ..., x_arg = "", y_arg = "") {
  out <- df_ptype2(x, y, ..., x_arg = x_arg, y_arg = y_arg)
  dribble_maybe_reconstruct(out)
}
#' @export
vec_ptype2.dribble.tbl_df <- function(x, y, ..., x_arg = "", y_arg = "") {
  tib_ptype2(x, y, ..., x_arg = x_arg, y_arg = y_arg)
}
#' @export
vec_ptype2.tbl_df.dribble <- function(x, y, ..., x_arg = "", y_arg = "") {
  tib_ptype2(x, y, ..., x_arg = x_arg, y_arg = y_arg)
}
#' @export
vec_ptype2.dribble.data.frame <- function(x, y, ..., x_arg = "", y_arg = "") {
  tib_ptype2(x, y, ..., x_arg = x_arg, y_arg = y_arg)
}
#' @export
vec_ptype2.data.frame.dribble <- function(x, y, ..., x_arg = "", y_arg = "") {
  tib_ptype2(x, y, ..., x_arg = x_arg, y_arg = y_arg)
}

# ------------------------------------------------------------------------------

# `vec_cast()`
#
# These methods are designed with `vec_ptype2()` in mind.
#
# Casting from one dribble to another will happen "automatically" when
# two dribbles are combined with `vec_c()`. The common type will be
# computed with `vec_ptype2()`, then each input will be `vec_cast()` to that
# common type. It should always be possible to reconstruct the dribble
# if `df_cast()` is able to cast the underlying data frames successfully.
#
# Casting a tibble or data.frame to a dribble should never happen
# automatically, because the ptype2 methods always push towards
# tibble / data.frame. Since it is so unlikely that this will be done
# correctly, we don't ever allow it.
#
# Casting a dribble to a tibble or data.frame is easy, the underlying
# vctrs function does the work for us. This is used when doing
# `vec_c(<dribble>, <tbl>)`, as the `vec_ptype2()` method will compute
# a common type of tibble, and then each input will be cast to tibble.

#' @export
vec_cast.dribble.dribble <- function(x, to, ..., x_arg = "", to_arg = "") {
  out <- df_cast(x, to, ..., x_arg = x_arg, to_arg = to_arg)
  dribble_maybe_reconstruct(out)
}
#' @export
vec_cast.dribble.tbl_df <- function(x, to, ..., x_arg = "", to_arg = "") {
  stop_incompatible_cast_dribble(x, to, x_arg = x_arg, to_arg = to_arg)
}
#' @export
vec_cast.tbl_df.dribble <- function(x, to, ..., x_arg = "", to_arg = "") {
  tib_cast(x, to, ..., x_arg = x_arg, to_arg = to_arg)
}
#' @export
vec_cast.dribble.data.frame <- function(x, to, ..., x_arg = "", to_arg = "") {
  stop_incompatible_cast_dribble(x, to, x_arg = x_arg, to_arg = to_arg)
}
#' @export
vec_cast.data.frame.dribble <- function(x, to, ..., x_arg = "", to_arg = "") {
  df_cast(x, to, ..., x_arg = x_arg, to_arg = to_arg)
}

# ------------------------------------------------------------------------------

stop_incompatible_cast_dribble <- function(x, to, ..., x_arg, to_arg) {
  details <- "Can't cast to a <dribble> because the resulting structure is likely invalid."
  stop_incompatible_cast(
    x,
    to,
    x_arg = x_arg,
    to_arg = to_arg,
    details = details
  )
}
