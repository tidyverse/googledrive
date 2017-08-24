#' List contents of a folder or Team Drive
#'
#' List the contents of a folder or Team Drive, nonrecursively. This is a thin
#' wrapper around [drive_find()], that simply limits the search to direct
#' children of a specific folder or to top-level items of a Team Drive.
#'
#' @param path Specifies a single folder on Google Drive whose contents you want
#'   to list. Can be an actual path (character), a file id or URL marked with
#'   [as_id()], or a [`dribble`]. If it is a Team Drive or is a folder on a Team
#'   Drive, it must be passed as a [`dribble`].
#' @param ... Any parameters that are valid for [drive_find()].
#'
#' @template dribble-return
#' @export
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
drive_ls <- function(path = NULL, ..., recursive = TRUE) {
  stopifnot(is.logical(recursive), length(recursive) == 1)
  if (is.null(path)) {
    return(drive_find(...))
  }

  if (is_path(path)) {
    path <- append_slash(path)
  }
  path <- as_dribble(path)
  path <- confirm_single_file(path)
  message_glue("\n\nname = {path$name}")

  dots <- list(...)
  if (is_team_drivy(path)) {
    if (is_team_drive(path)) {
      dots[["team_drive"]] <- as_id(path$id)
    } else {
      dots[["team_drive"]] <- as_id(path$drive_resource[[1]][["teamDriveId"]])
    }
  }

  params <- c(dots, c(q = glue("{sq(path$id)} in parents")))
  out <- do.call(drive_find, params)
  message_glue("number of files = {nrow(out)}")

  if (!recursive) return(out)

  folders <- out[is_folder(out), ]

  message_glue("number of folders = {nrow(folders)}")

  if (!some_files(folders)) return(out)

  dots[["recursive"]] <- TRUE
  foo <- purrr::map(folders$id, function(x) {dots[["path"]] <- as_id(x); dots})

  recurse_out <- lapply(foo, function(x) do.call(drive_ls, x))
  message_glue("{path$name}: length(recurse_out) = {length(recurse_out)}")

  c(list(out), recurse_out)
}
