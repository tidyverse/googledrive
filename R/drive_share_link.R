#' Retrieves Google Drive file's share link
#'
#' @param file `dribble` representing the file you would like to
#'   retrieve the link for
#'
#' @return character, link to Google Drive file
#' @export
drive_share_link <- function(file) {
  file <- as.dribble(file)
  purrr::map_chr(file$drive_file, "webViewLink")
}
