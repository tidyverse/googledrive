#' Download a file from Google Drive.
#'
#' @template file
#' @param out_path Character. Path for output file. Google files can
#'   be downloaded to types specified [here](https://developers.google.com/drive/v3/web/manage-downloads).
#' @param overwrite A logical scalar, do you want to overwrite a file that already
#'    exists locally?
#' @template verbose
#'
#' @examples
#' \dontrun{
#' ## Save "chickwts.csv" to the working directory as "chickwts.csv".
#' drive_download(file = "chickwts.csv", out_path = "chickwts.csv")
#'
#' ## Save Google Sheet named "chickwts" to the working directory as
#' ## "chickwts.csv".
#' drive_download(file = "chickwts", out_path = "chickwts.csv")
#'}
#' @export
drive_download <- function(file = NULL,
                           out_path = NULL,
                           overwrite = FALSE,
                           verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_single_file(file)

  if (is.null(out_path)) {
    stop("You must specify `out_path`.")
  }

  mime_type <- file$files_resource[[1]]$mimeType

  ## it seems that it needs an extenstion to save properly
  ext <- tools::file_ext(out_path)
  if (ext == "") {
    stop("Your file name in `out_path` must have an extension.")
  }

  if (!grepl("google", mime_type)) {

  request <- generate_request(endpoint = "drive.files.get",
                              params = list(alt = "media",
                                            fileId = file$id))
  } else {
    ## TODO check that extension is actually allowed per
    ## https://developers.google.com/drive/v3/web/manage-downloads
    mime_type <- drive_mime_type(ext)
    request <- generate_request(endpoint = "drive.files.export",
                                params = list(fileId = file$id,
                                              mimeType = mime_type ))
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

