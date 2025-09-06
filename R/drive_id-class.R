#' `drive_id` class
#'
#' @description

#' `drive_id` is an S3 class to mark strings as Drive file ids, in order to
#' distinguish them from Drive file names or paths. `as_id()` converts various
#' inputs into an instance of `drive_id`.
#'
#' `as_id()` is a generic function.

#' @param x A character vector of file or shared drive ids or URLs, a
#'   [`dribble`], or a suitable data frame.
#' @param ... Other arguments passed down to methods. (Not used.)
#' @return A character vector bearing the S3 class `drive_id`.
#' @name drive_id
#' @examplesIf drive_has_token()
#' as_id("123abc")
#' as_id("https://docs.google.com/spreadsheets/d/qawsedrf16273849/edit#gid=12345")
#'
#' x <- drive_find(n_max = 3)
#' as_id(x)
NULL

new_drive_id <- function(x = character()) {
  vec_assert(x, character())
  new_vctr(x, class = "drive_id", inherit_base_type = TRUE)
}

validate_drive_id <- function(x) {
  ok <- is_valid_drive_id(x)
  if (all(ok)) {
    return(x)
  }

  # proceed with plain character vector
  x <- vec_data(x)
  # pragmatism re: how to cli-style a path that is the empty string
  # this is related to the use of gargle_map_cli() for vectorized styling
  # if cli gains native vectorization, this may become unnecessary
  x[!nzchar(x)] <- "\"\""

  drive_abort(c(
    "A {.cls drive_id} must match this regular expression: \\
     {.code {drive_id_regex()}}",
    "Invalid input{?s}:{cli::qty(sum(!ok))}",
    bulletize(gargle_map_cli(x[!ok]), bullet = "x")
  ))
}

#' @export
#' @rdname drive_id
as_id <- function(x, ...) UseMethod("as_id")

#' @export
as_id.default <- function(x, ...) {
  drive_abort(
    "
    Don't know how to coerce an object of class {.cls {class(x)}} into \\
    a {.cls drive_id}."
  )
}

#' @export
as_id.NULL <- function(x, ...) NULL

#' @export
as_id.drive_id <- function(x, ...) x

#' @export
as_id.dribble <- function(x, ...) as_id(x$id)

#' @export
as_id.data.frame <- function(x, ...) as_id(validate_dribble(new_dribble(x)))

#' @export
as_id.character <- function(x, ...) {
  if (length(x) == 0L) {
    return(new_drive_id())
  }
  out <- map_chr(x, get_one_id)
  validate_drive_id(new_drive_id(out))
}

drive_id_regex <- function() "^[a-zA-Z0-9_-]+$"

is_valid_drive_id <- function(x) {
  # among practitioners, It Is Known that file IDs have >= 25 characters
  # but I'm not convinced the pros outweigh the cons re: checking length
  # for example, in tests, it's nice to not worry about this
  grepl(drive_id_regex(), x) | is.na(x)
}

is_drive_id <- function(x) {
  inherits(x, "drive_id")
}

#' @export
gargle_map_cli.drive_id <- function(x, ...) {
  NextMethod()
}

#' @export
vec_ptype2.drive_id.drive_id <- function(x, y, ...) new_drive_id()
#' @export
vec_ptype2.drive_id.character <- function(x, y, ...) character()
#' @export
vec_ptype2.character.drive_id <- function(x, y, ...) character()

#' @export
vec_cast.drive_id.drive_id <- function(x, to, ...) x
#' @export
vec_cast.drive_id.character <- function(x, to, ...) {
  validate_drive_id(new_drive_id(x))
}
#' @export
vec_cast.character.drive_id <- function(x, to, ...) vec_data(x)

#' @export
vec_ptype_abbr.drive_id <- function(x, ...) "drv_id"

#' @export
pillar_shaft.drive_id <- function(x, ...) {
  # The goal is to either see drive_id in full (which would allow, e.g. copy
  # and paste) or to truncate it severely and leave room for more interesting
  # columns, such as the Drive file name.
  # Anything in between these two extremes seems like a waste of horizontal space.

  x_valid <- !is.na(x)

  # It's important to keep NA in the vector!
  out <- rep(NA_character_, vec_size(x))
  out[x_valid] <- format(x[x_valid])
  out_short <- out

  # nchar("<drv_id>") is 8
  n <- 8
  trunkate <- function(x) {
    glue("{substr(x, 1, n - 1)}{cli::symbol$continue}")
  }
  out_width <- nchar(trimws(out))
  too_wide <- which(x_valid & out_width > n)
  if (any(too_wide)) {
    out_short[too_wide] <- trunkate(out_short[too_wide])
  }

  have_color <- cli::num_ansi_colors() > 1
  pillar::new_pillar_shaft_simple(
    out,
    short_formatted = out_short,
    na = if (have_color) pillar::style_na("NA") else "<NA>"
  )
}

## we anticipate file-id-containing URLs in these forms:
##       /d/FILE_ID   Drive file
## /folders/FILE_ID   Drive folder
##       id=FILE_ID   uploaded blob
id_regexp <- "(/d/|/folders/|id=)[^/?]+"

is_drive_url <- function(x) grepl("^http", x) & grepl(id_regexp, x)

get_one_id <- function(x) {
  if (!grepl("^http|/", x)) {
    return(x)
  }

  id_loc <- regexpr(id_regexp, x)
  if (id_loc == -1) {
    NA_character_
  } else {
    gsub("/d/|/folders/|id=", "", regmatches(x, id_loc))
  }
}
