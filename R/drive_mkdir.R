#' Create a folder on Google Drive.
#'
#' @template path
#' @param name Character. The name of the folder you would like to create, if
#'   not already specified in `path`.
#' @template verbose
#'
#' @template dribble-return
#'
#' @examples
#' \dontrun{
#' ## Create folder named "def" in folder "abc".
#' drive_mkdir(path = "abc/def")
#'
#' ## This will also create a folder named "def" in folder
#' ## "abc".
#' drive_mkdir(path = "abc/", name = "def")
#'
#' ## If we already have a `dribble` with folder content,
#' ## we can pipe it into the function.
#' abc <- as_dribble("abc")
#' abc %>%
#'  drive_mkdir(name = "def")
#'}
#' @export
drive_mkdir <- function(path = NULL, name = NULL, verbose = TRUE) {
  parent <- NULL

  path_name <- split_path_name(path, name, verbose)
  path <- path_name[["path"]]
  name <- path_name[["name"]]

  if (!is.null(path)) {
    if (is.character(path)) {
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
      message(glue_data(folder, "Folder NOT created:\n{name}"))
    }
  }
  invisible(folder)
}
