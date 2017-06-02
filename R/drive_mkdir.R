#' Create a folder on Google Drive
#'
#' @param dir character, name of the folder you would like to create
#' @param path character, path where you would like the folder on your Google Drive
#' @template verbose
#'
#' @template dribble-return
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

  folder <- as_dribble(drive_id(proc_res$id))

  success <- folder$name == dir
  if (verbose) {
    if (success) {
      message(
        glue::glue_data(
          folder,
          "You have successfully uploaded the folder: '{name}'."
          )
        )
    } else
      message(
        glue::glue_data(
          folder,
          "Uh oh, something went wrong. The folder '{name}' was not uploaded."
        )
      )
  }
  invisible(folder)
}

