#' Download a file from Google Drive.
#'
#' @template file
#' @param out_path Character. Path for output file. Will default to its Google Drive
#'   name. Google files must include the intended extension and can be downloaded to types
#'   specified in the [Drive API documentation](https://developers.google.com/drive/v3/web/manage-downloads).
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
#' ## Export a Google Document named "foobar" to the working directory as
#' ## "foobar.docx"
#' drive_download(file = "foobar", out_path = "foobar.docx")
#'}
#' @export
drive_download <- function(file = NULL,
                           out_path = NULL,
                           overwrite = FALSE,
                           verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_single_file(file)

  out_path <- out_path %||% file$name

  mime_type <- file$files_resource[[1]]$mimeType

  if (grepl("google", mime_type)) {
    ## TODO check that extension is actually allowed per
    ## https://developers.google.com/drive/v3/web/manage-downloads
    ext <- tools::file_ext(out_path)
    if (ext == "") {
      stop(
        glue::glue(
          "We don't know how to save the Google file: {sq(out_path)} \nPlease specify a file name with an exension in `out_path`."
          )
        )
    }
    mime_type <- drive_mime_type(ext)
    request <- generate_request(endpoint = "drive.files.export",
                                params = list(fileId = file$id,
                                              mimeType = mime_type ))
  } else {
    request <- generate_request(endpoint = "drive.files.get",
                                params = list(alt = "media",
                                              fileId = file$id))
  }

  response <- make_request(request, httr::write_disk(out_path, overwrite = overwrite))
  success <- file.exists(out_path)

  if (success) {
    if (verbose) {
      message(
        glue::glue("File downloaded from Google Drive:\n{sq(file$name)}\nSaved locally as:\n{sq(out_path)}")
      )
    }
  } else {
    spf("Zoinks! the file doesn't seem to have downloaded")
  }
  invisible(file)
}

