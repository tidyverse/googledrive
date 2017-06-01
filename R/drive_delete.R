#' Delete file from Google Drive
#'
#' @template file
#' @template verbose
#'
#' @return logical, indicating whether the delete succeeded
#' @export
#'
drive_delete <- function(file = NULL, verbose = TRUE) {

  file <- as.dribble(file)

  out <- purrr::map2_lgl(file$id, file$name, ~ {
  request <- build_request(endpoint = "drive.files.delete",
                           params = list(fileId = .x))
  response <- make_request(request)

  ## note, delete does not send a response header, so we
  ## will just stop for status & check the status code
  ## rather than using process_response()

  httr::stop_for_status(response)

  if (verbose == TRUE) {
    if (response$status_code == 204L) {
      message(
        glue::glue(
        "The file '{.y}' has been deleted from your Google Drive"
        )
      )
    } else {
      message(
        glue::glue(
        "Zoinks! Something went wrong, '{.y}' was not deleted."
        )
      )
    }
  }

  if (response$status_code == 204L) TRUE else FALSE
  })
  invisible(out)
}
