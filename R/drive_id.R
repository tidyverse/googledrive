#' Register Drive id.
#'
#' This adds the class `drive_id` to a character string.
#' @param x A character string, the Google drive id to register as class `drive_id`.
#'
#' @export
drive_id <- function(x) {
  stopifnot(is.character(x))
  structure(x, class = "drive_id")
}
