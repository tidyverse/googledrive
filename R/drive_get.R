#' Get Drive files by path or id
#'
#' @description Retrieve metadata for files specified via path or via file id.
#'
#' @template not-like-your-local-file-system
#'
#' @description If the files are specified via `path`, the returned [`dribble`]
#'   will include a `path` variable. To add path information to any [`dribble`]
#'   that lacks it, use [drive_reveal()], e.g., `drive_reveal(d, "path")`. If
#'   you want to list the contents of a folder, use [drive_ls()]. For general
#'   searching, use [drive_find()].
#'
#' @template team-drives-description
#'
#' @seealso Wraps the `files.get` endpoint and, if you specify files by name or
#'   path, also calls `files.list`:
#'   * <https://developers.google.com/drive/v3/reference/files/update>
#'   * <https://developers.google.com/drive/v3/reference/files/list>
#'
#' @param path Character vector of path(s) to get. Use a trailing slash to
#'   indicate explicitly that a path is a folder, which can disambiguate if
#'   there is a file of the same name (yes this is possible on Drive!). If
#'   `path` appears to contain Drive URLs or is explicitly marked with
#'   [as_id()], it is treated as if it was provided via the `id` argument.
#' @param id Character vector of Drive file ids or URLs (it is first processed
#'   with [as_id()]). If both `path` and `id` are non-`NULL`, `id` is silently
#'   ignored.
#' @template team_drive-singular
#' @template corpus
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
#' drive_get(id = "root") %>% drive_reveal("path")
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
#' ## apply to a browser URL for, e.g., a Google Sheet
#' my_url <- "https://docs.google.com/spreadsheets/d/FILE_ID/edit#gid=SHEET_ID")
#' drive_get(my_url)
#' drive_get(as_id(my_url))
#' drive_get(id = my_url)
#'
#' ## access the Team Drive named "foo"
#' ## team_drive params must be specified if getting by path
#' foo <- team_drive_get("foo")
#' drive_get(c("this.jpg", "that-file"), team_drive = foo)
#' ## team_drive params are not necessary if getting by id
#' drive_get(as_id("123456789"))
#'
#' ## search all Team Drives and other files user has accessed
#' drive_get(c("this.jpg", "that-file"), corpus = "all")
#' }
drive_get <- function(path = NULL,
                      id = NULL,
                      team_drive = NULL,
                      corpus = NULL,
                      verbose = TRUE) {
  if (length(path) + length(id) == 0) return(dribble_with_path())
  stopifnot(is.null(path) || is.character(path))
  stopifnot(is.null(id) || is.character(id))

  if (!is.null(path) && any(is_drive_url(path))) {
    path <- as_id(path)
  }

  if (!is.null(path) && inherits(path, "drive_id")) {
    id <- path
    path <- NULL
  }

  if (is.null(path)) {
    as_dribble(purrr::map(as_id(id), get_one_file))
  } else {
    dribble_from_path(path, team_drive, corpus)
  }
}

get_one_file <- function(id) {
  ## when id = "", drive.files.get actually becomes a call to drive.files.list
  ## and, therefore, returns 100 files by default ... don't let that happen
  if (!isTRUE(nzchar(id, keepNA = TRUE))) {
    stop_glue("File ids must not be NA and cannot be the empty string.")
  }
  request <- request_generate(
    endpoint = "drive.files.get",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  response <- request_make(request)
  gargle::response_process(response)
}

dribble_with_path <- function() {
  put_column(dribble(), nm = "path", val = character(), .after = "name")
}

dribble_with_path_for_root <- function() {
  put_column(root_folder(), nm = "path", val = "~/", .after = "name")
}
