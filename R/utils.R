last <- function(x) x[length(x)]

sq <- function(x) glue::single_quote(x)

## removes last abs(n) elements
crop <- function(x, n = 6L) if (n == 0) x else utils::head(x, -1 * abs(n))

## Sys.getenv() but for exactly 1 env var and returns NULL if unset
Sys_getenv <- function(x) {
  stopifnot(length(x) == 1)
  out <- Sys.getenv(x = x, unset = NA_character_)
  if (is.na(out)) NULL else out
}

## vectorized isTRUE()
is_true <- function(x) vapply(x, isTRUE, logical(1))

#' An expose object.
#'
#' `expose()` returns a sentinel object, similar in spirit to `NULL`, that tells
#' the calling function to return its internal data structure. googledrive
#' stores alot of information about the Drive API, MIME types, etc., internally
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
