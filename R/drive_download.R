#' Download a file from Google Drive.
#'
#' This function downloads files from Google Drive. Google type files (i.e.: Google Documents,
#' Google Sheets, Google Slides, etc.) must indicate the intended extension for the local file.
#' This can be indicated by specifying the full file name with the `out_path` parameter or indended
#' exension with the `type` parameter. Google type files can be downloaded to types specified in the
#' [Drive API documentation](https://developers.google.com/drive/v3/web/manage-downloads).
#' @template file
#' @param out_path Character. Path for output file. Will default to its Google Drive
#'   name.
#' @param type Character. Extension you would like for the local file.
#' @param overwrite A logical scalar, do you want to overwrite a file that already
#'    exists locally?
#' @template verbose
#'
#' @examples
#' \dontrun{
#' ## Save "chickwts.csv" to the working directory as "chickwts.csv".
#' drive_download(file = "chickwts.csv")
#'
#' ## Export a Google Sheet named "chickwts" to the working directory as
#' ## "chickwts.csv".
#' drive_download(file = "chickwts", out_path = "chickwts.csv")
#'
#' ## This will also export a Google Sheet named "chickwts" to the working
#' ## directory as "chickwts.csv".
#' drive_download(file = "chickwts", type = "csv")
#'
#' ## Export a Google Document named "foobar" to the working directory as
#' ## "foobar.docx".
#' drive_download(file = "foobar", out_path = "foobar.docx")
#'
#' ## This will also export a Google Document named "foobar" to the working
#' ## directory as "foobar.docx".
#' drive_download(file = "foobar", type = "docx")
#'}
#' @export
drive_download <- function(file = NULL,
                           out_path = NULL,
                           type = NULL,
                           overwrite = FALSE,
                           verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_single_file(file)

  ## preserve extension from out_path, before possible override by file$name
  ext <- file_ext_safe(out_path)
  out_path <- out_path %||% file$name

  mime_type <- file$files_resource[[1]]$mimeType

  if (!grepl("google", mime_type) && !is.null(type)) {
    message("Ignoring `type`. Only consulted for native Google file types.")
  }

  if (grepl("google", mime_type)) {
    export_type <- type %||% ext %||% get_export_mime_type(mime_type)
    export_type <- drive_mime_type(export_type)
    verify_export_mime_type(mime_type, export_type)
    out_path <- apply_extension(out_path, export_type)

    request <- generate_request(
      endpoint = "drive.files.export",
      params = list(
        fileId = file$id,
        mimeType = export_type
      )
    )
  } else {
    request <- generate_request(
      endpoint = "drive.files.get",
      params = list(
        fileId = file$id,
        alt = "media"
      )
    )
  }

  response <- make_request(
    request,
    httr::write_disk(out_path, overwrite = overwrite)
  )
  success <- httr::status_code(response) == 200 && file.exists(out_path)

  if (success) {
    if (verbose) {
      message(
        glue(
          "File downloaded from Google Drive:\n{sq(file$name)}\n",
          "Saved locally as:\n{sq(out_path)}"
        )
      )
    }
  } else {
    stop("Zoinks! the file doesn't seem to have downloaded", call. = FALSE)
  }
  invisible(file)
}

## get the default export MIME type for a native Google MIME type
## examples:
##    Google Doc --> MS Word
##  Google Sheet --> MS Excel
## Google Slides --> MS PowerPoint
get_export_mime_type <- function(mime_type) {
  m <- .drive$translate_mime_types$mime_type_google == mime_type &
    is_true(.drive$translate_mime_types$default)
  if (!any(m)) {
    stop(glue("Not a recognized Google MIME type:\n{mime_type}"), call. = FALSE)
  }
  .drive$translate_mime_types$mime_type_local[m]
}

## affirm that export_type is a valid export MIME type for a native Google file
## of type mime_type
verify_export_mime_type <- function(mime_type, export_type) {
  m <- .drive$translate_mime_types$mime_type_google == mime_type
  ok <- export_type %in% .drive$translate_mime_types$mime_type_local[m]
  if (!ok) {
    ## to be really nice, we would look these up in drive_mime_type() tibble
    ## and use the human_below, if found
    stop(
      glue(
        "Cannot export Google file of type:\n{mime_type}\n",
        "as a file of type:\n{export_type}"
      ),
      call. = FALSE
    )
  }
  export_type
}

## determine file extension from mime_type
## apply to out_path if not already present
apply_extension <- function(out_path, mime_type) {
  mime_tbl <- drive_mime_type()
  m <- mime_tbl$mime_type == mime_type
  if (sum(m) != 1) return(out_path)

  ext <- mime_tbl$ext[m]
  ext_orig <- file_ext_safe(out_path)
  if (!identical(ext, ext_orig)) {
    out_path <- paste(out_path, ext, sep = ".")
  }
  out_path
}
