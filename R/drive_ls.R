#' List contents of a folder.
#'
#' @param path Character. A single folder on Google Drive whose contents you
#'   want to list. Can be an actual path (character), a file id marked with [as_id()], or
#'   a [`dribble`].
#' @inheritParams drive_search
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

  if (is.character(path)) {
    path <- append_slash(path)
  }
  path <- as_dribble(path)
  path <- confirm_single_file(path)

  q_clause <- paste(sq(path$id), "in parents")
  if (!is.null(x$q)) {
    q_clause <- paste(x$q, "and", q_clause)
  }

  drive_search(pattern = pattern, type = type, q = q_clause)
}

#' List contents of a folder.
#' @inherit drive_ls
#' @examples
#' \dontrun{
#' ## get contents of the folder 'abc' (non-recursive)
#' drive_list("abc")
#'
#' ## get contents of folder 'abc' that contain the
#' ## letters 'def'
#' drive_list(path = "abc", pattern = "def")
#'
#' ## get all Google spreadsheets in folder 'abc'
#' ## that contain the letters 'def'
#' drive_list(path = "abc", pattern = "def", type = "spreadsheet")
#' }
#' @export
drive_list <- function(path = "~/", pattern = NULL, type = NULL, ...) {
  drive_ls(path = path, pattern = pattern, type = type, ...)
}
