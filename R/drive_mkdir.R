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
#' }
#' @export
drive_mkdir <- function(path = NULL, name = NULL, verbose = TRUE) {
  if (!is.null(name)) {
    stopifnot(is_path(name), length(name) == 1)
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
    stop(
      "New folder's name must be specified either via `path` or `name`.",
      call. = FALSE
    )
  }
  ## note that there are no API calls above here
  ## it means we can test more on travis/appveyor
  path <- path %||% root_folder()
  path <- as_dribble(path)
  if (!some_files(path)) {
    stop_glue("Requested parent folder does not exist.")
  }
  if (!single_file(path)) {
    paths <- glue::glue_data(path, "  * {name}: {id}")
    stop_collapse(
      c("Requested parent folder identifies multiple files:", paths)
    )
  }
  if (!is_folder(path)) {
    stop("`path` must be a single, pre-existing folder.", call. = FALSE)
  }

  request <- generate_request(
    endpoint = "drive.files.create",
    params = list(
      name = name,
      mimeType = "application/vnd.google-apps.folder",
      parents = list(path$id),
      fields = "*"
    )
  )

  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  folder <- as_dribble(list(proc_res))

  success <- folder$name == name
  if (verbose) {
    ## not entirely sure why this placement of `\n` helps glue do the right
    ## thing and yet ... it does
    message_glue("\nFolder {if (success) '' else 'NOT '}created:\n",
          "  * {folder$name}"
    )
  }
  invisible(folder)
}
