#' Lookup a mime type from a Google Drive type or file extension
#'
#' @param type Character. The Google Drive type or file extension you would
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
drive_mime_type <- function(type = NULL, verbose = TRUE) {

  if (!(is.character(type) && length(type) == 1)) {
    stop("Please update `type` to be a character string.", call. = FALSE)
  }

  mime_type <- .drive$mime_tbl$mime_type[.drive$mime_tbl$mime_type == type |
                                           (!is.na(.drive$mime_tbl$human_type) &
                                              (.drive$mime_tbl$human_type == type))
                                         ]
  if (length(mime_type) == 0L) {
    if (verbose) {
      message(glue::glue("Ignoring `type` input. We do not have a mime type for files of type: {sq(type)}"))
    }
    return(invisible(NULL))
  }
  mime_type
}
