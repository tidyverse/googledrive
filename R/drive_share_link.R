#' Retrieve a file's share link.
#'
#' @template file
#'
#' @return Character. The link to Google Drive file.
#' @export
drive_share_link <- function(file) {
  file <- as_dribble(file)
  file <- confirm_some_files(file)
  purrr::map_chr(file$drive_resource, "webViewLink")
}
