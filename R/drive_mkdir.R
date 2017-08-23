#' Create a folder
#'
#' @param folder Name for the new folder or, optionally, a path that specifies
#'   an existing parent folder, as well as the new name.
#' @param parent Target destination for the new folder, i.e. a folder or a Team
#'   Drive. Can be given as an actual path (character), a file id or URL marked
#'   with [as_id()], or a [`dribble`]. Defaults to your "My Drive" root folder.
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
#' drive_mkdir("def", parent = "abc")
#'
#' ## Another way to create a folder named "def" in folder "abc",
#' ## this time with parent folder stored in a dribble.
#' abc <- as_dribble("abc")
#' drive_mkdir("def", parent = abc)
#'
#' ## clean up
#' drive_ls(path = "abc", pattern = "^def$", type = "folder") %>% drive_rm()
#' }
#' @export
drive_mkdir <- function(folder, parent = NULL, verbose = TRUE) {
  stopifnot(is_string(folder))

  ## wire up to the conventional 'path' and 'name' pattern used elsewhere
  if (is.null(parent)) {
    path <- folder
    name <- NULL
  } else {
    path <- parent
    name <- folder
  }

  if (is_path(path)) {
    if (is.null(name)) {
      path <- strip_slash(path)
    }
    path_parts <- partition_path(path, maybe_name = is.null(name))
    path <- path_parts$parent
    name <- name %||% path_parts$name
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
