#' Lookup a mime type from a Google Drive type or file extension
#'
#' @param type Character. The Google Drive type or file extension you would
#'   like to look up the mime type of.
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
drive_mime_type <- function(type = NULL) {

  if (is.null(type)) {
    return(.drive$mime_tbl)
  }
  if (!(is.character(type))) {
    stop("`type` must be a character", call. = FALSE)
  }

  m <- match(
    type,
    .drive$mime_tbl$human_type,
    nomatch = NA_character_,
    incomparables = NA
  )
  m <- ifelse(is.na(m),
              match(type,
                    .drive$mime_tbl$mime_type,
                    nomatch = NA_character_,
                    incomparables = NA
              ),
              m
  )
  mime_type <- .drive$mime_tbl$mime_type[m]

  if (all(is.na(mime_type))) {
    stop(glue::glue("We do not know a mime type for files of type: {sq(type)}"),
         call. = FALSE)
  }
  mime_type
}
