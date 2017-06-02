#' Mark as Google Drive id.
#'
#' Marks a character vector as holding Google Drive file ids, as opposed to file
#' names or paths.
#'
#' @param x Character vector of Google Drive ids
#'
#' @export
drive_id <- function(x) {
  stopifnot(is.character(x))
  structure(x, class = "drive_id")
}
