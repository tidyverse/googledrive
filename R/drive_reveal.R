#' Add column(s) with new information
#'
#' `drive_reveal()` adds extra information about your Drive files that is not
#' automatically present in the default [`dribble`] produced by googledrive. Why
#' is this info not always present?
#'   1. You don't always care about it.
#'   2. It may require calling different endpoints in the Drive API. Example:
#'   getting a file's permissions.
#'   3. It might require additional API calls. Example: figuring out the path(s)
#'   associated with a specific file.
#'
#' @template not-like-your-local-file-system
#'
#' @section Trashed:
#' When `what = "trashed"`, the [`dribble`] gains a logical variable that
#' indicates whether a file is in the trash..
#'
#' @section MIME type: When `what = "mime_type"`, the [`dribble`] gains a
#'   variable of MIME types.
#'
#' @section Permissions:
#' When `what = "permissions"` the [`dribble`] gains a logical variable `shared`
#' that indicates whether a file is shared and a new list-column
#' `permissions_resource` containing lists of
#' [Permissions resources](https://developers.google.com/drive/v3/reference/permissions#resource).
#'
#' @section Publishing:
#' When `what = "publishing"` the [`dribble`] gains a logical variable
#' `published` that indicates whether a file is published and a new list-column
#' `revision_resource` containing lists of
#' [Revisions resources](https://developers.google.com/drive/v3/reference/revisions#resource).
#'
#' @template file-plural
#' @param what Character, describing the type of info you want to add:
#'   * path. Warning: this can be slow, especially if called on many files.
#'   * trashed
#'   * mime_type
#'   * permissions. Who is this file shared with and in which roles?
#'   * published
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## Get a nice, random selection of files
#' files <- drive_find(n_max = 10, q = "trashed = true or trashed = false")
#'
#' ## Reveal
#' ##   * paths (warning: can be slow for many files!)
#' ##   * if `trashed` or not
#' ##   * MIME type
#' ##   * permissions, i.e. sharing status
#' ##   * if `published` or not
#' drive_reveal(files, "path")
#' drive_reveal(files, "trashed")
#' drive_reveal(files, "mime_type")
#' drive_reveal(files, "permissions")
#' drive_reveal(files, "published")
#'
#' ## 'root' is a special file id that always represents your root folder
#' drive_get(id = "root") %>% drive_reveal("path")
#' }
drive_reveal <- function(file,
                         what = c("path", "trashed", "mime_type",
                                  "permissions", "published")) {
  file <- as_dribble(file)
  what <- match.arg(what)
  reveal <- switch(
    what,
    "path" = drive_reveal_path,
    "trashed" = drive_reveal_trashed,
    "mime_type" = drive_reveal_mime_type,
    "permissions" = drive_reveal_permissions,
    "published" = drive_reveal_published
  )
  reveal(file)
}

