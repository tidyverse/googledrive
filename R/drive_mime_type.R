#' Lookup MIME type
#'
#' @description This is a helper to determinine which MIME type should be used
#' for a file. Three types of input are acceptable:
#'   * Native Google Drive file types. Important examples:
#'     - "document" for Google Docs
#'     - "folder" for folders
#'     - "presentation" for Google Slides
#'     - "spreadsheet" for Google Sheets
#'   * File extensions, such as "pdf", "csv", etc.
#'   * MIME types accepted by Google Drive (these are simply passed through).
#'
#' @param type Character. Google Drive file type, file extension, or MIME type.
#'   Pass the sentinel [`expose()`] if you want to get the full table used for
#'   validation and lookup, i.e. all MIME types known to be relevant to the
#'   Drive API.
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
#' ## see the internal tibble of MIME types known to the Drive API
#' drive_mime_type(expose())
#' @export
drive_mime_type <- function(type = NULL) {

  if (is.null(type)) {
    return(invisible())
  }
  if (is_expose(type)) {
    return(.drive$mime_tbl)
  }
  if (!(is.character(type))) {
    stop_glue("'type' must be character")
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
    stop_glue(
      "\nUnrecognized 'type':\n  * {problems}",
      problems = collapse(type[is.na(mime_type)], sep = "\n")
    )
  }
  mime_type
}

#' Lookup extension from MIME type
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
    return(invisible())
  }
  stopifnot(is.character(type))

  type <- drive_mime_type(type)
  m <- purrr::map_int(type, one_ext)
  .drive$mime_tbl$ext[m]
}

one_ext <- function(type) {
  m <- which(.drive$mime_tbl$mime_type %in% type &
               is_true(.drive$mime_tbl$default))
  if (length(m) == 0L) {
    m <- NA_integer_
  }
  m
}

drive_reveal_mime_type <- function(file) {
  confirm_dribble(file)
  if (no_file(file)) {
    return(
      put_column(dribble(), nm = "mime_type", val = character(), .after = "name")
    )
  }
  promote(file, "mime_type")
}
