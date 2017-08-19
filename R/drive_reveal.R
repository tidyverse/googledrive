#' Add columns with pertinent information to your dribble
#'
#' @template file-plural
#' @param what Character.
#'  * publish
#'  * permissions
#'  * trash
#'  * path
#'  * mime_type
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## Upload a file
#' file <- drive_upload(R.home('doc/html/logo.jpg'))
#'
#' ## Reveal `trash` status
#' drive_reveal(file, what = "trash")
#'
#' ## Reveal `permissions`
#' drive_reveal(file, what = "permissions")
#'
#' ## Reveal `publish` status
#' drive_reveal(file, what = "publish")
#'
#' ## Clean up
#' drive_rm(file)
#' }
drive_reveal <- function(file,
                         what = c("path", "trashed", "mime_type",
                                  "permissions", "published")) {
  file <- as_dribble(file)
  what <- match.arg(what)
  reveal <- switch(
    what,
    "path" = drive_reveal_path,
    "trashed" = drive_reveal_trash,
    "mime_type" = drive_reveal_mime_type,
    "permissions" = drive_reveal_permissions,
    "published" = drive_reveal_published
  )
  reveal(file)
}

