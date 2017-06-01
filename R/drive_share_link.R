#' Retrieves Google Drive file's share link
#'
#' @param file `dribble` representing the file you would like to
#'   retrieve the link for
#'
#' @return character, link to Google Drive file
#' @export
drive_share_link <- function(file) {
  file <- as.dribble(file)
  file$drive_file[[1]]$webViewLink
}
