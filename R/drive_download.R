#' Download a Drive file
#'
#' @description This function downloads a file from Google Drive. Native Google
#'   file types, such as Google Docs, Google Sheets, and Google Slides, must be
#'   exported to a conventional local file type. This can be specified:

#'   * explicitly via `type`
#'   * implicitly via the file extension of `path`
#'   * not at all, i.e. rely on the built-in default
#'
#' @description To see what export file types are even possible, see the [Drive
#'   API
#'   documentation](https://developers.google.com/drive/api/v3/ref-export-formats)
#'    or the result of `drive_about()$exportFormats`. The returned dribble
#'   includes a `local_path` column.
#'
#' @seealso [Download
#'   files](https://developers.google.com/drive/v3/web/manage-downloads#downloading_google_documents),
#'    in the Drive API documentation.
#'
#' @template file-singular
#' @param path Character. Path for output file. If absent, the default file name
#'   is the file's name on Google Drive and the default location is working
#'   directory, possibly with an added file extension.
#' @param type Character. Only consulted if `file` is a native Google file.
#'   Specifies the desired type of the exported file. Will be processed via
#'   [drive_mime_type()], so either a file extension like `"pdf"` or a full MIME
#'   type like `"application/pdf"` is acceptable.
#' @param overwrite A logical scalar. If local `path` already exists, do you
#'   want to overwrite it?
#' @template verbose
#' @eval return_dribble()
#' @export
#' @examplesIf drive_has_token()
#' # Target one of the official example files
#' (src_file <- drive_example_remote("chicken_sheet"))
#'
#' # Download Sheet as csv, explicit type
#' downloaded_file <- drive_download(src_file, type = "csv")
#'
#' # See local path to new file
#' downloaded_file$local_path
#'
#' # Download as csv, type implicit in file extension
#' drive_download(src_file, path = "my_csv_file.csv")
#'
#' # Download with default name and type (xlsx)
#' drive_download(src_file)
#'
#' # Clean up
#' unlink(c("chicken_sheet.csv", "chicken_sheet.xlsx", "my_csv_file.csv"))
drive_download <- function(file,
                           path = NULL,
                           type = NULL,
                           overwrite = FALSE,
                           verbose = deprecated()) {
  warn_for_verbose(verbose)
  if (!is.null(path) && file.exists(path) && !overwrite) {
    drive_abort(c(
      "Local {.arg path} already exists and overwrite is {.code FALSE}:",
      bulletize(gargle_map_cli(path, "{.path <<x>>}"))
    ))
  }
  file <- as_dribble(file)
  file <- confirm_single_file(file)

  ## preserve extension from path, before possible override by file$name
  ext <- file_ext_safe(path)
  path <- path %||% file$name

  mime_type <- file$drive_resource[[1]]$mimeType

  if (!grepl("google", mime_type) && !is.null(type)) {
    drive_bullets(c(
      "!" = "Ignoring {.arg type}. Only consulted for native Google file types.",
      " " = "MIME type of {.arg file}: {.field mime_type}."
    ))
  }

  if (grepl("google", mime_type)) {
    export_type <- type %||% ext %||% get_export_mime_type(mime_type)
    export_type <- drive_mime_type(export_type)
    verify_export_mime_type(mime_type, export_type)
    path <- apply_extension(path, drive_extension(export_type))

    request <- request_generate(
      endpoint = "drive.files.export",
      params = list(
        fileId = file$id,
        mimeType = export_type
      )
    )
  } else {
    request <- request_generate(
      endpoint = "drive.files.get",
      params = list(
        fileId = file$id,
        alt = "media"
      )
    )
  }

  response <- request_make(
    request,
    httr::write_disk(path, overwrite = overwrite)
  )
  success <- httr::status_code(response) == 200 && file.exists(path)

  if (success) {
    drive_bullets(c(
      "File downloaded:",
      bulletize(gargle_map_cli(file)),
      "Saved locally as:",
      "*" = "{.path {path}}"
    ))
  } else {
    drive_abort("Download failed.")
  }
  invisible(put_column(file, nm = "local_path", val = path, .after = "name"))
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
    drive_abort(c(
      "Not a recognized Google MIME type:",
      bulletize(gargle_map_cli(mime_type), bullet = "x")
    ))
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
    ## and use the human_type, if found
    drive_abort(c(
      "Cannot export Google file of type:",
      bulletize(gargle_map_cli(mime_type)),
      "as a file of type:",
      bulletize(gargle_map_cli(export_type))
    ))
  }
  export_type
}
