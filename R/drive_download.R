#' Download a file from Google Drive
#'
#' @template file
#' @param to Character, local path for the file download. Will default to
#'   saving to the working directory by its name on Google Drive.
#' @param overwrite A logical scalar, do you want to overwrite a local file
#'   if such exists?
#' @param fun Function used to write the downloaded file type.
#' @template verbose
#'
#' @example
#' \dontrun{
#' ## download a .csv file
#' drive_download("chickwts.csv", fun = write.csv)
#'
#' ## download a .rda file
#' drive_download("chickwts.rda", fun = writeBin)
#' }
#'
#' @export
drive_download <- function(file = NULL,
                           to = NULL,
                           overwrite = FALSE,
                           fun = writeBin,
                           verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_single_file(file)

  if (is.null(to)) {
    to <- file$name
  }

  if (file.exists(to) && overwrite == FALSE) {
    stop(glue::glue("File already exists:\n{file}\nSet `overwrite = TRUE` to overwrite."),
         call. = FALSE)
  }

  request <- generate_request(endpoint = "drive.files.get",
                              params = list(alt = "media",
                                            fileId = file$id))
  response <- make_request(request)
  httr::stop_for_status(response)
  proc_res <- httr::content(response, encoding = "raw")
  fun(proc_res, to)

  success <- response$status_code == 200

  if (success) {
    if (verbose) {
      message(
        glue::glue("File downloaded from Google Drive:\n{file$name}\n",
                   "to local path:\n{to}")
      )
    }
  } else {
    spf("Zoinks! the file doesn't seem to have downloaded")
  }

}
