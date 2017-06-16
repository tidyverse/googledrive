#' Lookup MIME type
#'
#' This is a helper to determinine which MIME type should be used for a file.
#' Three specific types of input are acceptable:
#' \itemize{
#' \item Google Drive "native" file types. Important examples:
#'   \itemize{
#'   \item "document" for Google Docs
#'   \item "folder" for folders
#'   \item "presentation" for Google Slides
#'   \item "spreadsheet" for Google Sheets
#'   }
#' \item File extensions, such as "pdf", "csv", etc.
#' \item MIME types accepted by Google Drive (these are simply passed through).
#' }
#' If no input is provided, function returns the full tibble used for lookup,
#' i.e. a tibble of MIME types known to be relevant to the Drive API.
#'
#' @param type Character. Google Drive file type, file extension, or MIME type.
#'
#' @return Character. MIME type.
#'
#' @examples
#' ## get the mime type for Google Spreadsheets
#' drive_mime_type("spreadsheet")
#'
#' ## get the mime type for jpegs
#' drive_mime_type("jpeg")
#'
#' ## it's vectorized
#' drive_mime_type(c("presentation", "pdf", "image/gif"))
#' @export
#' @noMd
drive_mime_type <- function(type = NULL) {

  if (is.null(type)) {
    return(.drive$mime_tbl)
  }
  if (!(is.character(type))) {
    stop("`type` must be character", call. = FALSE)
  }

  human_m <- match(
    type,
    .drive$mime_tbl$human_type,
    nomatch = NA_character_,
    incomparables = NA
  )
  ext_m <- match(
    type,
    .drive$mime_tbl$mime_type,
    nomatch = NA_character_,
    incomparables = NA
  )
  m <- ifelse(is.na(human_m), ext_m, human_m)
  mime_type <- .drive$mime_tbl$mime_type[m]

  if (all(is.na(mime_type))) {
    stop(glue::glue(
      "Unrecognized `type`:\n{problems}",
      problems = glue::collapse(type[is.na(mime_type)], sep = "\n")
      ),
      call. = FALSE
    )
  }
  mime_type
}
