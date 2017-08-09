#' Get Drive files by path or id
#'
#' @description Retrieve metadata for files specified via path or via file id.
#'   Note that Google Drive does NOT behave like your local file system:
#'   * You can get zero, one, or more files back for each file name or path! On
#'     Google Drive, file and folder names need not be unique, even at a given
#'     level of the hierarchy.
#'   * A file or folder can also have multiple direct parents, so a single Drive
#'     file can potentially be represented by multiple paths.
#' @description In contrast, a file id will always identify at most one Drive
#' file. Finally, note also that a folder is just a specific type of file on
#' Drive.
#'
#' If the files are specified via `path`, versus `id`, the returned [`dribble`]
#' will include a `path` variable. To add path information to any [`dribble`]
#' that lacks it, use [drive_add_path()]. If you want to list the contents of a
#' folder, use [drive_ls()]. For general searching, use [drive_find()].
#'
#' @seealso Wraps the `files.get` endpoint and, if you specify files by name or
#'   path, also calls `files.list`:
#'   * <https://developers.google.com/drive/v3/reference/files/update>
#'   * <https://developers.google.com/drive/v3/reference/files/list>
#'
#' @param path Character vector of path(s) to get. Use a trailing slash to
#'   indicate explicitly that a path is a folder, which can disambiguate if
#'   there is a file of the same name (yes this is possible on Drive!). A
#'   character vector marked with [as_id()] is treated as if it was provided via
#'   the `id` argument.
#' @param id Character vector of Drive file ids or URLs (it is first processed
#'   with [as_id()]). If both `path` and `id` are non-`NULL`, `id` is silently
#'   ignored.
#' @template team_drive-singular
#' @template corpora
#' @template verbose
#'
#' @template dribble-return
#' @export
#'
#' @examples
#' \dontrun{
#' ## get info about your "My Drive" root folder
#' drive_get("~/")
#' ## the API reserves the file id "root" for your root folder
#' drive_get(id = "root")
#' drive_get(id = "root") %>% drive_add_path()
#'
#' ## multiple names
#' drive_get(c("abc", "def"))
#'
#' ## multiple names, one of which must be a folder
#' drive_get(c("abc", "def/"))
#'
#' ## query by file id(s)
#' drive_get(id = "abcdefgeh123456789")
#' drive_get(as_id("abcdefgeh123456789"))
#' drive_get(id = c("abcdefgh123456789", "jklmnopq123456789"))
#'
#' }
drive_get <- function(path = NULL,
                      id = NULL,
                      team_drive = NULL,
                      corpora = NULL,
                      verbose = TRUE) {
  if (length(path) + length(id) == 0) return(dribble_with_path())

  if (!is.null(path) && inherits(path, "drive_id")) {
    id <- path
    path <- NULL
  }

  if (!is.null(path)) {
    stopifnot(is_path(path))
    return(dribble_from_path(path, team_drive, corpora))
  }

  stopifnot(is.character(id))
  as_dribble(purrr::map(as_id(id), get_one_id))
}

get_one_id <- function(id) {
  ## when id = "", drive.files.get actually becomes a call to drive.files.list
  ## and, therefore, returns 100 files by default ... don't let that happen
  if (!isTRUE(nzchar(id, keepNA = TRUE))) {
    stop_glue("File ids must not be NA and cannot be the empty string.")
  }
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
