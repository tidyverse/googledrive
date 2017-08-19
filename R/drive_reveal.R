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
drive_reveal <- function(file, what = "path") {
  file <- as_dribble(file)
  reveal <- list("publish" = drive_show_publish,
                 "permissions" = drive_show_permissions,
                 "trash" = drive_show_trash,
                 "path" = drive_show_path,
                 "mime_type" = drive_show_mime_type)

  if (!(what %in% names(reveal))) {
    stop_glue(
      "\n'what' must be one of the following:\n",
      "  * {collapse(names(reveal), sep = ', ')}."
    )
  }

  reveal <- reveal[[what]]
  ## should it return an invisible file?
  reveal(file)
}

