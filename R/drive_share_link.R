#' Retrieves Google Drive file's share link
#'
#' @template dribble
#'
#' @return character, link to Google Drive file
#' @export
drive_share_link <- function(file) {
  file <- as.dribble(file)
  purrr::map_chr(file$file_resource, "webViewLink")
}
