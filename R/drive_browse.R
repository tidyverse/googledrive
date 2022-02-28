#' Retrieve Drive file links
#'
#' Returns the `"webViewLink"` for one or more files, which is the "link for
#' opening the file in a relevant Google editor or viewer in a browser".
#'
#' @template file-plural
#'
#' @return Character vector of file hyperlinks.
#' @export
#' @examplesIf drive_has_token()
#' # get a few files into a dribble
#' three_files <- drive_find(n_max = 3)
#'
#' # get their browser links
#' drive_link(three_files)
drive_link <- function(file) {
  file <- as_dribble(file)
  links <- map_chr(
    file$drive_resource,
    "webViewLink",
    .default = NA_character_
  )
  # no documented, programmatic way to get browser links for shared drives
  # but this seems to work ... I won't document it either, though
  sd <- is_shared_drive(file)
  links[sd] <- glue(
    "https://drive.google.com/drive/folders/{id}",
    id = as_id(file)[sd]
  )
  links
}

#' Visit Drive file in browser
#'
#' Visits a file on Google Drive in your default browser.
#'
#' @template file-singular
#'
#' @return Character vector of file hyperlinks, from [drive_link()], invisibly.
#' @export
#' @examplesIf drive_has_token() && rlang::is_interactive()
#' drive_find(n_max = 1) %>% drive_browse()
drive_browse <- function(file = .Last.value) {
  file <- as_dribble(file)
  links <- drive_link(file)
  if (!interactive() || no_file(file)) {
    return(invisible(links))
  }
  if (!single_file(file)) {
    drive_bullets(c("v" = "Browsing the first file of {nrow(file)}."))
  }
  utils::browseURL(links[1])
  invisible(links)
}
