#' Create a folder on Google Drive.
#'
#' @param name Character. The name of the folder you would like to create.
#' @template path
#' @template verbose
#'
#' @template dribble-return
#' @export
drive_mkdir <- function(name = NULL, path = NULL, verbose = TRUE) {
  parent <- NULL

  if (!is.null(path)) {
    if (inherits(path, "character")) {
      path <- append_slash(path)
    }
    path <- as_dribble(path)
    path <- confirm_single_file(path)
    if (!is_folder(path)) {
      stop(
        glue_data(path, "'path' is not a folder:\n{name}"),
        call. = FALSE
      )
    }
    parent <- path$id
  }

  request <- generate_request(
    endpoint = "drive.files.create",
    params = list(
      name = name,
      mimeType =  "application/vnd.google-apps.folder",
      parents = list(parent),
      fields = "*"
    )
  )

  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  folder <- as_dribble(list(proc_res))

  success <- folder$name == name
  if (verbose) {
    if (success) {
      message(glue_data(folder, "Folder created:\n{name}"))
    } else {
      message(glue_data(folder, "Uh oh, folder NOT created:\n{name}"))
    }
  }
  invisible(folder)
}
