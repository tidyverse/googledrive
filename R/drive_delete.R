#' Delete file from Google Drive
#'
#' @param file `gfile` object representing the file you would like to
#'   delete
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#' @return logical, indicating whether the delete succeeded
#' @export
#'
drive_delete <- function(file = NULL, verbose = TRUE) {
  request <- build_drive_delete(file = file)
  response <- make_request(request)
  process_drive_delete(response = response,
                       file = file,
                       verbose = verbose)

}

build_drive_delete <- function(file = NULL,
                               token = drive_token()) {
  if (!inherits(file, "gfile")) {
    spf("Input must be a `gfile`. See `drive_file()`")
  }

  id <- file$id
  url <- file.path(.state$drive_base_url_files_v3, id)

  build_request(endpoint = url,
                token = token,
                method = "DELETE")
}

process_drive_delete <- function(response = NULL,
                                 file = NULL,
                                 verbose = TRUE) {
  process_request(response, content = FALSE)

  if (verbose == TRUE) {
    if (response$status_code == 204L) {
      message(sprintf(
        "The file '%s' has been deleted from your Google Drive",
        file$name
      ))
    } else {
      message(sprintf(
        "Zoinks! Something went wrong, '%s' was not deleted.",
        file$name
      ))
    }
  }

  if (response$status_code == 204L)
    invisible(TRUE)
  else
    invisible(FALSE)
}
