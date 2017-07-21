#' Delete files from Drive.
#'
#' @description Caution: this will permanently delete your files! For a safer,
#'   reversible option, see [drive_trash()].
#'
#' @template file
#' @template verbose
#'
#' @return Logical vector, indicating whether the delete succeeded.
#' @export
#'
drive_rm <- function(file = NULL, verbose = TRUE) {
  file <- as_dribble(file)
  if (no_file(file) && verbose) {
    message_glue("No such files found to delete.")
    return(invisible(logical(0)))
  }

  out <- purrr::map_lgl(file$id, delete_one)

  if (verbose) {
    if (any(out)) {
      successes <- glue::glue_data(file[out, ], "  * {name}: {id}")
      message_collapse(c("Files deleted:", successes))
    }
    if (any(!out)) {
      failures <- glue::glue_data(file[!out, ], "  * {name}: {id}")
      message_collapse(c("Files NOT deleted:", failures))
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
