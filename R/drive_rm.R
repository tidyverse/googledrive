#' Delete files from Drive
#'
#' Caution: this will permanently delete your files! For a safer, reversible
#' option, see [drive_trash()].
#'
#' @seealso Wraps the `files.delete` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/delete>
#'
#' @template file
#' @template verbose
#'
#' @return Logical vector, indicating whether the delete succeeded.
#' @export
#'
#' @examples
#' \dontrun{
#' ## Create a folder to remove
#' folder <- drive_mkdir("folder-to-remove")
#'
#' ## Remove folder
#' drive_rm(folder)
#' }
drive_rm <- function(file = NULL, verbose = TRUE) {
  file <- as_dribble(file)
  if (no_file(file) && verbose) {
    message("No such files found to delete.")
    return(invisible(logical(0)))
  }

  out <- purrr::map_lgl(file$id, delete_one)

  if (verbose) {
    if (any(out)) {
      successes <- glue_data(file[out, ], "  * {name}: {id}")
      message_collapse(c("Files deleted:", successes))
    }
    if (any(!out)) {
      failures <- glue_data(file[!out, ], "  * {name}: {id}")
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
