#' Create a folder on Google Drive
#'
#' @param dir character, name of the folder you would like to create
#' @param path character, path where you would like the folder on your Google Drive
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#' @return object of class `gfile` and `list` that contains uploaded folder's
#'   information
#' @export
drive_mkdir <- function(dir = NULL, path = NULL, verbose = TRUE) {
  parent <- NULL

  if (!is.null(path)) {
    path <- append_slash(path)
    parent <- get_one_path(path)$id
  }

  request <- build_request(
    endpoint = "drive.files.create.meta",
    params = list(
      name = dir,
      mimeType =  "application/vnd.google-apps.folder",
      parents = list(parent)
    )
  )

  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  folder <- drive_file(proc_res$id)

  success <- folder$name == dir
  if (verbose) {
    if (success) {
      message(sprintf(
        "You have successfully uploaded the folder: '%s'.",
        proc_res$name
      ))
    } else
      message(
        sprintf(
          "Uh oh, something went wrong. The folder '%s' was no uploaded.",
          proc_res$name
        )
      )
  }
  invisible(drive_file(proc_res$id))
}

