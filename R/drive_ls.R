#' List contents of a folder.
#'
#' List the contents of a folder on Google Drive, nonrecursively. This is a thin
#' wrapper around [drive_find()], that simply limits the search to a specific
#' folder.
#'
#' @param path Specifies a single folder on Google Drive whose contents you want
#'   to list. Can be an actual path (character), a file id or URL marked with
#'   [as_id()], or a [dribble].
#' @param ... Any parameters that are valid for [drive_find()].
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
drive_ls <- function(path = NULL, ...) {
  if (is.null(path)) {
    return(drive_find(...))
  }

  if (is_path(path)) {
    path <- append_slash(path)
  }
  path <- as_dribble(path)
  path <- confirm_single_file(path)

  params <- list(...)
  params <- append(params, c(q = paste(sq(path$id), "in parents")))
  do.call(drive_find, params)
}
