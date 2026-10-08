isFALSE <- function(x) identical(x, FALSE)

is_toggle <- function(x) length(x) == 1L && is.logical(x)

last <- function(x) pluck(x, length(x))

escape_regex <- function(x) {
  chars <- c(
    "*",
    ".",
    "?",
    "^",
    "+",
    "$",
    "|",
    "(",
    ")",
    "[",
    "]",
    "{",
    "}",
    "\\"
  )
  gsub(
    paste0("([\\", paste0(collapse = "\\", chars), "])"),
    "\\\\\\1",
    x,
    perl = TRUE
  )
}

## put a column into a tibble in the REST sense: "create or update"
## tibble::add_column() except
##   1. can only add 1 column
##   2. if column by this name already exists, overwrite it in place
##   3. provide `nm` and `val` separately
put_column <- function(.data, nm, val, .before = NULL, .after = NULL) {
  if (nm %in% names(.data)) {
    .data[[nm]] <- val
    .data
  } else {
    tibble::add_column(.data, !!nm := val, .before = .before, .after = .after)
  }
}

## vectorized isTRUE()
is_true <- function(x) vapply(x, isTRUE, logical(1))

#' An expose object
#'
#' `expose()` returns a sentinel object, similar in spirit to `NULL`, that tells
#' the calling function to return its internal data structure. googledrive
#' stores a lot of information about the Drive API, MIME types, etc., internally
#' and then exploits it in helper functions, like [`drive_mime_type()`],
#' [`drive_fields()`], [`drive_endpoints()`], etc. We use these objects to
#' provide nice defaults, check input validity, or lookup something cryptic,
#' like MIME type, based on something friendlier, like a file extension. Pass
#' `expose()` to such a function if you want to inspect its internal object, in
#' its full glory. This is inspired by the `waiver()` object in ggplot2.
#'
#' @export
#' @keywords internal
#' @examples
#' drive_mime_type(expose())
#' drive_fields(expose())
expose <- function() structure(list(), class = "expose")

is_expose <- function(x) inherits(x, "expose")

## partition a parameter list into two parts, using names to identify
## components destined for the second part
## example input:
# partition_params(
#   list(a = "a", b = "b", c = "c", d = "d"),
#   c("b", "c")
# )
## example output:
# list(
#   unmatched = list(a = "a", d = "d"),
#   matched = list(b = "b", c = "c")
# )
partition_params <- function(input, nms_to_match) {
  out <- list(
    unmatched = input,
    matched = list()
  )
  if (length(nms_to_match) && length(input)) {
    m <- names(out$unmatched) %in% nms_to_match
    out$matched <- out$unmatched[m]
    out$unmatched <- out$unmatched[!m]
  }
  out
}
