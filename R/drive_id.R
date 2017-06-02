#' Register Drive id
#'
#' This addes the class `drive_id` to a character string.
#' @param x character, drive id to register
#'
#' @export
drive_id <- function(x) {
  stopifnot(is.character(x))
  structure(x, class = "drive_id")
}
