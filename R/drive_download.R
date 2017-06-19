#' Download a file from Google Drive.
#'
#' @template file
#' @param out_path Character. Path for output file. If `NULL`, we will
#'    default to save a file to working directory by name of the Google
#'    Drive file.
#' @param type Character. If the file is a Google Drive type (Google Doc,
#'    Google Sheet, Google Slide, etc.), you must specify the type of file
#'    you would like to save (by file exension). This can be specified either
#'    by using the `type` parameter, or by specifying the extension with the
#'    `out_path` parameter.
#' @param overwrite A logical scalar, do you want to overwrite a file that already
#'    exists locally?
#' @template verbose
#'
#' @return An object of class `drive_file` containing raw data from
#'   your downloaded Google Drive file.
#'
#' @examples
#' \dontrun{
#' ## save "chickwts.csv" to the working directory as "chickwts.csv".
#' drive_download(file = "chickwts.csv")
#'
#' ## save Google Sheet named "chickwts" to the working directory as
#' ## chickwts.csv
#' drive_download(file = "chickwts", out_file = "chickwts.csv")
#' }
#'
#' @export
drive_download <- function(file = NULL,
                           out_path = NULL,
                           type = NULL,
                           overwrite = FALSE,
                           verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_single_file(file)

  if (is.null(out_path)) {
    out_path <- file$name
  }

  mime_type <- file$files_resource[[1]]$mimeType

  if (!grepl("google", mime_type)) {

  request <- generate_request(endpoint = "drive.files.get",
                              params = list(alt = "media",
                                            fileId = file$id))
  } else {
    ## TODO make sure the type is compatable.
    type <- type %||% tools::file_ext(out_path)
    if (type == "") {
      ## TODO, be able to guess type by default (for example saving sheets
      ## as csvs..)
      stop("We cannot guess type yet")
    }
    mime_type <- drive_mime_type(type)
    request <- generate_request(endpoint = "drive.files.export",
                                params = list(fileId = file$id,
                                              mimeType = mime_type ))
  }

  ## it seems that it needs an extenstion to save properly
  ext <- tools::file_ext(out_path)
  if (ext == "") {
    ext <- .drive$mime_tbl$ext[.drive$mime_tbl$mime_type == mime_type]
    out_path <- paste0(out_path, ".", ext)
  }

  response <- make_request(request, httr::write_disk(out_path, overwrite = overwrite))
  success <- response$status_code == 200

  if (success) {
    if (verbose) {
      message(
        glue::glue("File downloaded from Google Drive:\n{file$name}\nSaved locally as:\n{out_path}")
      )
    }
  } else {
    spf("Zoinks! the file doesn't seem to have downloaded")
  }
  invisible(file)
}

