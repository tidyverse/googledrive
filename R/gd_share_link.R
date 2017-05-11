#' Retrieves Google Drive file's share link
#'
#' @param file `drive_file` object representing the file you would like to
#'   retrieve the link for
#'
#' @return character, link to Google Drive file
#' @export
gd_share_link <- function(file) {
  if(!inherits(file, "drive_file")){
    spf("Input must be a `drive_file`. See `gd_file()`")
  }
  file$kitchen_sink$webViewLink
}
