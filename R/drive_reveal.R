#' Add columns with pertinent information to your dribble
#' @template file-plural
#' @param what Character.
#'  * publish
#'  * sharing
#'  * trash
#'  * path
#'  * mime_type
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' drive_reveal(file, what = "trash")
#' }
drive_reveal <- function(file, what) {

  reveal <- list("publish" = drive_show_publish,
                 "sharing" = drive_show_sharing,
                 "trash" = drive_show_trash,
                 "path" = drive_show_path,
                 "mime_type" = drive_show_mime_type)[[what]]
  reveal(file)
}
## should it return an invisible file?

