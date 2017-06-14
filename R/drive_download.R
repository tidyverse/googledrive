#' Download a file from Google Drive.
#'
#' @template file
#' @template verbose
#'
#' @return An object of class \code{dribble}, a tibble with
#'    one row per file. A column `raw_file` is added with
#'    raw data from your downloaded Google Drive file. This
#'    can be extracted using [drive_extract_file()].
#' @examples
#' \dontrun{
#' ## download a .csv file
#' drive_download("chickwts.csv") %>%
#'   drive_extract_file() %>%
#'   write.csv("chickwts.csv")
#'
#' ## download an .rda file
#' drive_download("chickwts.rda") %>%
#'   drive_extract_file() %>%
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
  proc_res <- httr::content(response, encoding = "raw")

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
  file <- tibble::add_column(file, raw_file = list(proc_res))
  file
}

#' Extract raw file from `dribble`.
#'
#' @param x A [`dribble`] with one row and a `raw_file` column, obtained after
#'   running [drive_download()].
#'
#' @examples
#' \dontrun{
#' ## download a .csv file
#' drive_download("chickwts.csv") %>%
#'   drive_extract_file() %>%
#'   write.csv("chickwts.csv")
#'
#' ## download an .rda file
#' drive_download("chickwts.rda") %>%
#'   drive_extract_file() %>%
#'   writeBin("chickwts.rda")
#' }
#'
#' @export
drive_extract_file <- function(x) {
  stopifnot(inherits(x, "dribble"))
  if (!("raw_file" %in% colnames(x))) {
    stop("Input must be a `dribble` containing a downloaded `raw_file`. See `drive_download()`.")
  }
  x$raw_file[[1]]
}
