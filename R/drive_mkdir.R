#' Create a folder on Drive.
#'
#' @template path
#' @templateVar name folder
#' @templateVar default If not given or unknown, will default to the "My Drive" root folder.
#' @template name
#' @templateVar name folder
#' @templateVar default {}
#' @template verbose
#'
#' @template dribble-return
#'
#' @examples
#' \dontrun{
#' ## Create folder named "def" in existing folder "abc".
#' drive_mkdir("abc/def")
#'
#' ## This will also create a folder named "def" in folder "abc".
#' drive_mkdir(path = "abc", name = "def")
#'
#' ## Another way to create a folder named "def" in folder "abc",
#' ## this time with parent folder stored in a dribble.
#' abc <- as_dribble("abc")
#' drive_mkdir(path = abc, name = "def")
#'
#' ## Yet another way to do this,
#' ## this time with parent folder provide via id.
#' drive_mkdir(path = as_id(abc$id), name = "def")
#'
#' ## clean up
#' drive_ls(path = "abc", pattern = "^def$", type = "folder") %>% drive_rm()
#' }
#' @export
drive_mkdir <- function(path = NULL, name = NULL, verbose = TRUE) {
  if (!is.null(name)) {
    stopifnot(is_string(name))
  }

  if (is_path(path)) {
    if (is.null(name)) {
      path <- strip_slash(path)
    }
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name
  }

  if (is.null(name)) {
    stop_glue("New folder's name must be specified either via 'path' or 'name'.")
  }
  params <- list(
    name = name,
    mimeType = "application/vnd.google-apps.folder",
    fields = "*"
  )

  if (!is.null(path)) {
    path <- as_parent(path)
    params[["parents"]] <- list(path$id)
  }

  request <- generate_request(
    endpoint = "drive.files.create",
    params = params
  )
  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  folder <- as_dribble(list(proc_res))

  success <- folder$name == name
  if (verbose) {
    new_path <- paste0(append_slash(path$name), folder$name)
    message_glue(
      "\nFolder {if (success) '' else 'NOT '}created:\n",
      "  * {new_path}"
    )
  }
  invisible(folder)
}
