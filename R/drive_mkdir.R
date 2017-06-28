#' Create a folder on Google Drive.
#'
#' @param name Character. The name of the folder you would like to create.
#' @template folder
#' @template verbose
#'
#' @template dribble-return
#' @export
drive_mkdir <- function(name = NULL, folder = NULL, verbose = TRUE) {
  parent <- NULL

  if (!is.null(folder)) {
    if (inherits(folder, "character")) {
      folder <- append_slash(folder)
    }
    folder <- as_dribble(folder)
    folder <- confirm_single_file(folder)
    if (!is_folder(folder)) {
      stop(
        glue_data(folder, "'folder' is not a folder:\n{name}"),
        call. = FALSE
      )
    }
    parent <- folder$id
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
