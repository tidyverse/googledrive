#' Lookup a mime type from a Google Drive type or file extension
#'
#' @param x Character. The Google Drive type or file extension you would
#'   like to look up the mime type of.
#' @template verbose
#'
#' @return Character. The mime type of input.
#'
#' @examples
#' ## get the mime type for Google Spreadsheets
#' drive_mime_type("spreadsheet")
#'
#' ## get the mime type for jpegs
#' drive_mime_type("jpeg")
#' @export
drive_mime_type <- function(x, verbose = TRUE) {
  stopifnot(is.character(x))
  purrr::map_chr(x, one_mime_type, verbose = verbose)
}

one_mime_type <- function(x, verbose = TRUE) {
  mime_type <- .drive$mime_tbl$mime_type[.drive$mime_tbl$mime_type == x |
                                           (!is.na(.drive$mime_tbl$human_type) &
                                              (.drive$mime_tbl$human_type == x))
                                         ]
  if (length(mime_type) == 0L) {
    if (verbose) {
      message(glue::glue("We do not have a mime type for files of type: {sq(x)}"))
    }
    mime_type <- NA_character_
  }
  mime_type
}
