#' Create a folder on Google Drive.
#'
#' @param dir Character. The name of the folder you would like to create.
#' @param path Character. The path of the parent folder.
#' @template verbose
#'
#' @template dribble-return
#' @export
drive_mkdir <- function(dir = NULL, path = NULL, verbose = TRUE) {
  parent <- NULL

  ## TO DO: accept path input in the generalized "Drive file" style
  ## and check that it's a folder
  if (!is.null(path)) {
    path <- append_slash(path)
    parent <- get_one_path(path)$id
  }

  request <- build_request(
    endpoint = "drive.files.create.meta",
    params = list(
      name = dir,
      mimeType =  "application/vnd.google-apps.folder",
      parents = list(parent),
      fields = "*"
    )
  )

  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  folder <- as_dribble(list(proc_res))

  success <- folder$name == dir
  if (verbose) {
    if (success) {
      message(glue::glue_data(folder, "Folder created:\n{name}"))
    } else {
      message(glue::glue_data(folder, "Uh oh, folder NOT created:\n{name}"))
    }
  }
  invisible(folder)
}

