#' Retrieve file links
#'
#' Returns the `"webViewLink"` for one or more files, which is the "link for
#' opening the file in a relevant Google editor or viewer in a browser".
#'
#' @template file
#'
#' @return Character vector of file hyperlinks.
#' @export
#' @examples
#' \dontrun{
#' ## get a few files into a dribble
#' three_files <- drive_find(n_max = 3)
#'
#' ## get their browser links
#' drive_link(three_files)
#' }
drive_link <- function(file) {
  file <- as_dribble(file)
  links <- purrr::map_chr(
    file$drive_resource,
    "webViewLink",
    .default = NA_character_
  )
  ## no documented, programmatic way to get browser links for Team Drives
  ## but this seems to work ... I won't document it either, though
  td <- is_teamdrive(file)
  links[td] <- glue(
    "https://drive.google.com/drive/folders/{id}",
    id = as_id(file)[td]
  )
  links
}

#' Visit file in browser
#'
#' Visits a file on Google Drive in your default browser.
#'
#' @template file
#'
#' @return Character vector of file hyperlinks, from [drive_link()], invisibly.
#' @export
#' @examples
#' \dontrun{
#' drive_find(n_max = 1) %>% drive_browse()
#' }
drive_browse <- function(file = .Last.value) {
  file <- as_dribble(file)
  links <- drive_link(file)
  if (!interactive() || no_file(file)) return(invisible(links))
  if (!single_file(file)) {
    message_glue("Browsing the first file of {nrow(file)}.")
  }
  utils::browseURL(links[1])
  return(invisible(links))
}
