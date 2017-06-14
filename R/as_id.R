#' File id from string or URL.
#'
#' Marks a character vector as holding Google Drive file ids, as opposed to file
#' names or paths. User can supply either a Google Drive id or a Google Drive URL.
#'
#' @param x Character vector of Google Drive ids or Google Drive URLs
#'
#' @export
as_id <- function(x) {
  stopifnot(is.character(x))
  if (length(x) == 0L) {
    return(x)
  }

  x <- purrr::map_chr(x, one_id)

  structure(x, class = "drive_id")
}

one_id <- function(x) {
  if (!grepl("^http|/", x)) {
    return(x)
  }
  ## We expect the links to have /d/ before the file id, have /folders/
  ## before a folder id, or have id= before an uploaded blob
  id_loc <- regexpr("/d/([^/])+|/folders/([^/])+|id=([^/])+", x)
  if (id_loc == -1) {
      NA_character_
  } else {
      gsub("/d/|/folders/|id=", "", regmatches(x, id_loc))
  }
}
