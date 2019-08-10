#' Rename a Drive file
#'
#' This is a wrapper for [`drive_mv()`] that only renames a file.
#' If you would like to rename AND move the file, see [`drive_mv()`].
#'
#' @template file-singular
#' @param name Character. Name you would like the file to have.
#' @template overwrite
#' @template verbose
#'
#' @template dribble-return
#'
#' @examples
#' \dontrun{
#' ## Create a folder to rename
#' folder <- drive_mkdir("folder-to-rename")
#'
#' ## Rename folder
#' folder <- folder %>%
#'   drive_rename(name = "renamed-folder")
#'
#' ## Clean up
#' drive_rm(folder)
#' }
#' @export
drive_rename <- function(file, name = NULL, overwrite = NA, verbose = TRUE) {
  drive_mv(file = file, name = name, overwrite = overwrite, verbose = verbose)
}
