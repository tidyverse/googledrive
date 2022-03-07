#' List contents of a folder or shared drive
#'
#' List the contents of a folder or shared drive, recursively or not. This is a
#' thin wrapper around [drive_find()], that simply adds one constraint: the
#' search is limited to direct or indirect children of `path`.
#'
#' @param path Specifies a single folder on Google Drive whose contents you want
#'   to list. Can be an actual path (character), a file id or URL marked with
#'   [as_id()], or a [`dribble`]. If it is a shared drive or is a folder on a
#'   shared drive, it must be passed as a [`dribble`]. If `path` is a shortcut
#'   to a folder, it is automatically resolved to its target folder.
#' @param ... Any parameters that are valid for [drive_find()].
#' @param recursive Logical, indicating if you want only direct children of
#'   `path` (`recursive = FALSE`, the default) or all children, including
#'   indirect (`recursive = TRUE`).
#'
#' @eval return_dribble()
#' @export
#' @examples
#' \dontrun{
#' # get contents of the folder 'abc' (non-recursive)
#' drive_ls("abc")
#'
#' # get contents of folder 'abc' whose names contain the letters 'def'
#' drive_ls(path = "abc", pattern = "def")
#'
#' # get all Google spreadsheets in folder 'abc'
#' # whose names contain the letters 'def'
#' drive_ls(path = "abc", pattern = "def", type = "spreadsheet")
#'
#' # get all the files below 'abc', recursively, that are starred
#' drive_ls(path = "abc", q = "starred = true", recursive = TRUE)
#' }
drive_ls <- function(path = NULL, ..., recursive = FALSE) {
  stopifnot(is.logical(recursive), length(recursive) == 1)
  if (is.null(path)) {
    return(drive_find(...))
  }

  path <- as_parent(path)

  params <- list2(...)
  if (is_shared_drive(path)) {
    params[["shared_drive"]] <- as_id(path)
  } else {
    shared_drive <- pluck(path, "drive_resource", 1, "driveId")
    if (!is.null(shared_drive)) {
      params[["shared_drive"]] <- params[["shared_drive"]] %||% as_id(shared_drive)
    }
  }

  parent <- path[["id"]]
  if (isTRUE(recursive)) {
    parent <- c(parent, folders_below(parent))
  }
  parent <- glue("{sq(parent)} in parents")
  parent <- glue("({or(parent)})")
  params[["q"]] <- append(params[["q"]], parent)

  exec(drive_find, !!!params)
}

folders_below <- function(id) {
  folder_kids <- folder_kids_of(id)
  if (length(folder_kids) == 0) {
    character()
  } else {
    c(
      folder_kids,
      unlist(lapply(folder_kids, folders_below), recursive = FALSE)
    )
  }
}

folder_kids_of <- function(id) {
  shared_drive_id <- drive_get(id)$drive_resource[[1]]$driveId
  drive_find(
    shared_drive = as_id(shared_drive_id),
    type = "folder",
    q = glue("{sq(id)} in parents"),
    fields = prep_fields(c("kind", "name", "id"))
  )[["id"]]
}
