isFALSE <- function(x) identical(x, FALSE)

last <- function(x) x[length(x)]

sq <- function(x) glue::single_quote(x)
bt <- function(x) glue::backtick(x)

trim_ws <- function(x) {
  sub("\\s*$", "", sub("^\\s*", "", x))
}

and <- function(x) glue_collapse(x, sep = " and ")
or <- function(x) glue_collapse(x, sep = " or ")

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

stop_glue <- function(..., .sep = "", .envir = parent.frame(),
                      call. = FALSE, .domain = NULL) {
  stop(
    glue(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                           call. = FALSE, .domain = NULL) {
  stop(
    glue_data(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_collapse <- function(x) stop(glue_collapse(x, sep = "\n"), call. = FALSE)

message_glue <- function(..., .sep = "", .envir = parent.frame(),
                         .domain = NULL, .appendLF = TRUE) {
  message(
    glue(..., .sep = .sep, .envir = .envir),
    domain = .domain, appendLF = .appendLF
  )
}

message_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                              .domain = NULL) {
  message(
    glue_data(..., .sep = .sep, .envir = .envir),
    domain = .domain
  )
}

message_collapse <- function(x) message(glue_collapse(x, sep = "\n"))

warning_glue <- function(..., .sep = "", .envir = parent.frame(),
                         call. = FALSE, .domain = NULL) {
  warning(
    glue(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

warning_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                              call. = FALSE, .domain = NULL) {
  warning(
    glue_data(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

warning_collapse <- function(x) warning(glue_collapse(x, sep = "\n"))

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

#' An expose object
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

glue_collapse <- function(x, sep = "", width = Inf, last = "") {
  if (utils::packageVersion("glue") > "1.2.0") {
    utils::getFromNamespace("glue_collapse", "glue")(x = x, sep = sep, width = width, last = last)
  } else {
    utils::getFromNamespace("collapse", "glue")(x = x, sep = sep, width = width, last = last)
  }
}

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
