#' Download a file from Google Drive.
#'
#' @template file
#' @template verbose
#'
#' @return An object of class `drive_file` containing raw data from
#'   your downloaded Google Drive file.
#'
#' @examples
#' \dontrun{
#' ## download a .csv file
#' drive_download("chickwts.csv") %>%
#'   write.csv("chickwts.csv")
#'
#' ## download an .rda file
#' drive_download("chickwts.rda") %>%
#'   writeBin("chickwts.rda")
#' }
#'
#' @export
drive_download <- function(file = NULL, verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_single_file(file)

  request <- generate_request(endpoint = "drive.files.get",
                              params = list(alt = "media",
                                            fileId = file$id))
  response <- make_request(request)
  httr::stop_for_status(response)
  proc_res <- httr::content(response, encoding = "UTF-8")

  success <- response$status_code == 200

  if (success) {
    if (verbose) {
      message(
        glue::glue("File downloaded from Google Drive:\n{file$name}")
      )
    }
  } else {
    spf("Zoinks! the file doesn't seem to have downloaded")
  }
  structure(proc_res, class = c(class(proc_res), "drive_file"))
}

#' Write Google File as a csv
#'
#' @template file
#' @param path Character. Path to write to.
#' @template verbose
#'
#' @export
drive_write_csv <- function(file = NULL, path = NULL, verbose = TRUE) {
  file <- drive_download(file, verbose = verbose)
  if (!inherits(file, "data.frame")) {
    stop(glue::glue("File cannot be written as a .csv: {file$name}"))
  }
  write.csv(file, file = path)
  invisible(file)
}
