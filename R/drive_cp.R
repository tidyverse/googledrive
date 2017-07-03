#' Copy a Google Drive file.
#'
#' `drive_copy()` is an alias for `drive_cp()`.
#'
#' @template file
#' @template verbose
#'
#' @template dribble-return
#'
#' @examples
#' \dontrun{
#' ## Copy the file "chickwts.rda" in the same folder as the
#' ## original file as "Copy of chickwts.rda".
#' drive_cp("chickwts.rda")
#'
#' ## Copy multiple files - this will create files
#' ## "Copy of chickwts.rda" and "Copy of chickwts.csv"
#' ## in their same folder as the respective original files.
#' drive_cp(c("chickwts.rda", "chickwts.csv"))
#' }
#' @export
drive_cp <- function(file = NULL, verbose = TRUE) {
  files <- as_dribble(file)
  files <- confirm_some_files(files)
  if (any(is_folder(files))) {
    folders <- glue_data(files[is_folder(files), ], "  * {name}: {id}")
    msg <- collapse(
      c("The Drive API does not copy folders:", folders),
      sep = "\n"
    )
    stop(msg, call. = FALSE)
  }

  cp_files <- purrr::map(files$id, copy_one, verbose = verbose)
  cp_files <- do.call(rbind, cp_files)
  success <- purrr::map_lgl(cp_files$name, ~ grepl(files$name[1], .x))
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

copy_one <- function(id, verbose) {
  request <-  generate_request(
    endpoint = "drive.files.copy",
    params = list(
      fileId = id,
      fields = "*"
    )
  )
  res <- make_request(request)
  proc_res <- process_response(res)

  file <- as_dribble(list(proc_res))

  if (!grepl("Copy of", file$name)) {
    file <- drive_rename(
      file,
      paste("Copy of", file$name),
      verbose = FALSE
    )
  }

  return(file)
}

#' @rdname drive_cp
#' @export
drive_copy <- drive_cp
