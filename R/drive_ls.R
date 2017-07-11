#' List contents of a folder.
#'
#' List the contents of a folder on Google Drive, nonrecursively. Optionally,
#' filter for a regex in the file names and/or on MIME type. This is a thin
#' wrapper around [`drive_find()`].
#'
#' @param path Specifies a single folder on Google Drive whose contents you want
#'   to list. Can be an actual path (character), a file id marked with
#'   [as_id()], or a [dribble].
#' @inheritParams drive_find
#'
#' @template dribble-return
#' @export
#'
#' @examples
#' \dontrun{
#' ## get contents of the folder 'abc' (non-recursive)
#' drive_ls("abc")
#'
#' ## get contents of folder 'abc' that contain the
#' ## letters 'def'
#' drive_ls(path = "abc", pattern = "def")
#'
#' ## get all Google spreadsheets in folder 'abc'
#' ## that contain the letters 'def'
#' drive_ls(path = "abc", pattern = "def", type = "spreadsheet")
#' }
drive_ls <- function(path = "~/", pattern = NULL, type = NULL, ...) {

  x <- list(...)

  if (is_path(path)) {
    path <- append_slash(path)
  }
  path <- as_dribble(path)
  path <- confirm_single_file(path)

  q_clause <- paste(sq(path$id), "in parents")
  if (!is.null(x$q)) {
    q_clause <- paste(x$q, "and", q_clause)
  }
  x$q <- q_clause

  do.call(
    drive_find,
    c(pattern = pattern, type = type, x)
  )
}
