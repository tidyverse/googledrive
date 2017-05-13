#' Retrieves Google Drive file's share link
#'
#' @param file `gfile` object representing the file you would like to
#'   retrieve the link for
#'
#' @return character, link to Google Drive file
#' @export
drive_share_link <- function(file) {
  if (!inherits(file, "gfile")){
    spf("Input must be a `gfile`. See `drive_file()`")
  }
  file$kitchen_sink$webViewLink
}
