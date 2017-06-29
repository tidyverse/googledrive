#' Rename Google Drive file
#'
#' @template file
#' @param name Character. Name you would like the file to have.
#' @template verbose
#'
#' @template dribble-return
#'
#' @examples
#' \dontrun{
#' drive_rename("chickwts.csv", name = "my_chickwts.csv")
#' }
#' @export
drive_rename <- function(file = NULL, name = NULL, verbose = TRUE) {
  drive_mv(file = file, name = name, verbose = verbose)
}
