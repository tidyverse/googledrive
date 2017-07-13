#' Delete file from Drive.
#'
#' @template file
#' @template verbose
#'
#' @return Logical, indicating whether the delete succeeded.
#' @export
#'
drive_rm <- function(file = NULL, verbose = TRUE) {
  del_file <- as_dribble(file)
  if (!some_files(del_file) && verbose) {
    message(glue("No such files found to delete."))
  }

  out <- purrr::map_lgl(del_file$id, delete_one)

  if (verbose) {
    if (any(out)) {
      successes <- glue_data(del_file[out, ], "  * {name}: {id}")
      message(collapse(c("Files deleted:", successes), sep = "\n"))
    }
    if (any(!out)) {
      failures <- glue_data(del_file[!out, ], "  * {name}: {id}")
      message(collapse(c("Files NOT deleted:", failures), sep = "\n"))
    }
  }
  invisible(out)
}

delete_one <- function(id) {
  request <- generate_request(
    endpoint = "drive.files.delete",
    params = list(fileId = id)
  )
  response <- make_request(request)
  process_response(response)
}
