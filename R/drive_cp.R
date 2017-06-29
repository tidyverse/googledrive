#' Copy a Google Drive file.
#'
#' @template file
#' @template verbose
#'
#' @template dribble-return
#'
#' @examples
#' ## Copy the file "chickwts.rda" in the same folder as the
#' ## original file as "Copy of chickwts.rda".
#' drive_cp("chickwts.rda")
#'
#' ## Copy multiple files - this will create files
#' ## "Copy of chickwts.rda" and "Copy of chickwts.csv"
#' ## in their same folder as the respective original files.
#' drive_cp(c("chickwts.rda", "chickwts.csv"))
#' @export
drive_cp <- function(file = NULL, verbose = TRUE) {
  files <- as_dribble(file)
  files <- confirm_some_files(files)
  cp_files <- purrr::map(files$id, copy_one, verbose = verbose)
  cp_files <- do.call(rbind, cp_files)
  success <- purrr::map_lgl(file, ~grepl(.x, cp_files$name))
  if (verbose) {
    if (any(success)) {
      successes <- glue("  * {file[success]} -> {cp_files$name[success]}")
      message(collapse(c("Files copied:", successes), sep = "\n"))
    }
    if (any(!success)) {
      failures <- glue("  * {file[!success]}")
      message(collapse(c("Files NOT copied:", failures), sep = "\n"))
    }
  }
  invisible(cp_files)
}

copy_one <- function(id, name, verbose) {
  request <-  generate_request(
    endpoint = "drive.files.copy",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  proc_res <- do_request(request)

  file <- as_dribble(list(proc_res))

  if (!grepl("Copy of", file$name)) {
    file <- drive_rename(file,
                         paste("Copy of", file$name),
                         verbose = FALSE)
  }

  return(file)
}

#' Copy a Google Drive file.
#' @inherit drive_cp
#' @examples
#' ## this will make a copy of the file "chickwts.rda"
#' ## in the same folder as the original file named
#' ## "Copy of chickwts.rda".
#' drive_copy("chickwts.rda")
drive_copy <- function(file = NULL, verbose = TRUE) {
  drive_cp(file = file, verbose = verbose)
}
