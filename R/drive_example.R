#' Get path to example file
#'
#' googledrive comes bundled with a few small files to use in examples. This
#' function make them easy to access.
#'
#' @param path Name of file. If `NULL`, the example files will be listed.
#' @export
#' @examples
#' drive_example()
#' drive_example("chicken.jpg")
drive_example <- function(path = NULL) {
  if (is.null(path)) {
    list.files(
      system.file("extdata", package = "googledrive"),
      pattern = "chicken"
    )
  } else {
    system.file("extdata", path, package = "googledrive", mustWork = TRUE)
  }
}
