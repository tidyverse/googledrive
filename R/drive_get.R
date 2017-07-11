#' Get Drive files by path or id
#'
#' @description Retrieve metadata for files that match one or more paths or file
#' ids. Note that Google Drive does NOT behave like your local file system:
#'   * You can get zero, one, or more files back for each file name or path! On
#'     Google Drive, file and folder names need not be unique, even at a given
#'     level of the hierarchy.
#'   * A file or folder can also have multiple direct parents, so a single Drive
#'     file can potentially be represented by multiple paths.
#' @description In contrast, a file id will always identify at most one Drive
#' file. Finally, note also that a folder is just a specific type of file on
#' Drive.
#'
#' @param path Character vector of path(s) to get. Use a trailing slash to
#'   indicate explicitly that a path is a folder, which can disambiguate if
#'   there is a file of the same name (yes this is possible on Drive!). A
#'   character vector explicitly marked with [as_id()] is treated as if it was
#'   provided via the `id` argument.
#' @param id Character vector of Drive file ids, such as you might see in the
#'   URL when visiting a file on Google Drive. If both `path` and `id` are
#'   non-`NULL`, `id` is silently ignored.
#' @template verbose
#'
#' @return dribble-return
#' @export
#' @seealso If you want to list the contents of a folder, use [drive_ls()]. For
#'   general searching, use [drive_find()].
#'
#' @examples
#' \dontrun{
#' ## get info about your "My Drive" root folder
#' drive_get("~/")
#' ## the API reserves the file id "root" for your root folder
#' drive_get(id = "root")
#'
#' ## file(s) named 'abc'
#' drive_get("abc")
#'
#' ## folder(s) named 'abc'
#' drive_get("abc/")
#'
#' ## file(s) named 'def' with your My Drive root folder as direct parent
#' drive_get("~/def")
#'
#' ## multiple names
#' drive_get(c("abc", "def"))
#'
#' ## multiple folders
#' drive_get(c("abc/", "def/"))
#'
#' ## query by file id(s)
#' drive_get(id = "abcdefgeh123456789")
#' drive_get(as_id("abcdefgeh123456789"))
#' drive_get(id = c("abcdefgh123456789", "jklmnopq123456789"))
#'
#' }
drive_get <- function(path = NULL, id = NULL, verbose = TRUE) {
  if (length(path) + length(id) < 1) return(dribble())

  if (!is.null(path) && inherits(path, "drive_id")) {
    id <- path
    path <- NULL
  }

  if (!is.null(path)) {
    return(do.call(rbind, purrr::map(path, get_one_path)))
  }

  as_dribble(purrr::map(id, get_one_id))
}

get_one_id <- function(id) {
  stopifnot(is.character(id))
  ## when id = "", drive.files.get actually becomes a call to drive.files.list
  ## and, therefore, returns 100 files by default
  stopifnot(nzchar(id, keepNA = TRUE))
  request <- generate_request(
    endpoint = "drive.files.get",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  response <- make_request(request)
  process_response(response)
}

get_one_path <- function(path = "~/", verbose = TRUE) {
  stopifnot(is_path(path))
  if (length(path) < 1) return(dribble())
  stopifnot(length(path) == 1, !is.na(path))
  path_tbl <- get_paths(path = path, partial_ok = FALSE)
  as_dribble(path_tbl[names(path_tbl) != "path"])
}
