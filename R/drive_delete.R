#' Delete file from Google Drive.
#'
#' @template file
#' @template verbose
#'
#' @return Logical, indicating whether the delete succeeded.
#' @export
#'
drive_delete <- function(file = NULL, verbose = TRUE) {
  file <- as_dribble(file)
  out <- purrr::map2_lgl(file$id, file$name, delete_one, verbose = verbose)
  invisible(out)
}

delete_one <- function(id, name, verbose = TRUE) {
  request <- build_request(
    endpoint = "drive.files.delete",
    params = list(fileId = id)
  )
  response <- make_request(request)

  ## note, delete does not send a response header, so we
  ## will just stop for status & check the status code
  ## rather than using process_response()

  httr::stop_for_status(response)

  if (verbose) {
    if (httr::status_code(response) == 204L) {
      message(glue::glue("File deleted from Google Drive:\n{name}"))
    } else {
      message(glue::glue("Zoinks! File NOT deleted:\n{name}"))
    }
  }
  response$status_code == 204L
}
