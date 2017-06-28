#' Lookup MIME type.
#'
#' @description This is a helper to determinine which MIME type should be used
#' for a file. Three types of input are acceptable:
#'   * Google Drive "native" file types. Important examples:
#'     - "document" for Google Docs
#'     - "folder" for folders
#'     - "presentation" for Google Slides
#'     - "spreadsheet" for Google Sheets
#'   * File extensions, such as "pdf", "csv", etc.
#'   * MIME types accepted by Google Drive (these are simply passed through).
#'
#' @description If `type = all`, function returns the full table used
#' for lookup, i.e. all MIME types known to be relevant to the Drive
#' API.
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
#'
#' ## get tibble of all mime types recognized by Google Drive
#' drive_mime_type("all")
#' @export
drive_mime_type <- function(type = NULL) {

  if (is.null(type)) {
    return(invisible(NULL))
  }
  if (!(is.character(type))) {
    stop("`type` must be character", call. = FALSE)
  }
  if (length(type) == 1 && type == "all") {
    return(.drive$mime_tbl)
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
    stop(glue(
      "Unrecognized `type`:\n{problems}",
      problems = collapse(type[is.na(mime_type)], sep = "\n")
    ),
    call. = FALSE
    )
  }
  mime_type
}

#' Lookup extension from MIME type.
#'
#' @description This is a helper to determinine which extension should be used
#' for a file. Two types of input are acceptable:
#'   * MIME types accepted by Google Drive.
#'   * File extensions, such as "pdf", "csv", etc. (these are simply passed through).
#'
#' @param type Character. MIME type or file extension.
#'
#' @return Character. File extension.
#'
#' @examples
#'
#' ## get the extension for mime type image/jpeg
#' drive_extension("image/jpeg")
#'
#' ## it's vectorized
#' drive_extension(c("text/plain", "pdf", "image/gif"))
#' @export
drive_extension <- function(type = NULL) {

  if (is.null(type)) {
    return(invisible(NULL))
  }
  if (!(is.character(type))) {
    stop("`type` must be character", call. = FALSE)
  }

  type <- drive_mime_type(type)
  m <- purrr::map_dbl(type, one_ext)
  .drive$mime_tbl$ext[m]
}

one_ext <- function(type) {
  m <- which(.drive$mime_tbl$mime_type %in% type & is_true(.drive$mime_tbl$default))
  if (length(m) == 0L) {
    m <- NA
  }
  m
}
