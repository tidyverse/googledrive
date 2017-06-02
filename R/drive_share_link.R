#' Retrieves Google Drive file's share link.
#'
#' @template file
#'
#' @return A character string, link to Google Drive file.
#' @export
drive_share_link <- function(file) {
  file <- as_dribble(file)
  purrr::map_chr(file$files_resource, "webViewLink")
}
