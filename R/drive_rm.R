#' Delete files from Drive
#'
#' Caution: this will permanently delete your files! For a safer, reversible
#' option, see [drive_trash()].
#'
#' @seealso Wraps the `files.delete` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/files/delete>
#'
#' @param ... One or more Drive files, specified in any valid way, i.e. as a
#' [`dribble`], by name or path, or by file id or URL marked with [as_id()]. Or
#' any combination thereof. Elements are processed with [as_dribble()] and
#' row-bound prior to deletion.
#' @template verbose
#'
#' @return Logical vector, indicating whether the delete succeeded.
#' @export
#'
#' @examples
#' \dontrun{
#' ## Create something to remove
#' drive_upload(system.file("DESCRIPTION"), name = "abc-DESC")
#'
#' ## Remove it by name
#' drive_rm("abc-DESC")
#'
#' ## Create several things to remove
#' x1 <- drive_upload(system.file("DESCRIPTION"), name = "abc-DESC")
#' drive_upload(system.file("DESCRIPTION"), name = "def-DESC")
#' x2 <- drive_upload(system.file("DESCRIPTION"), name = "ghi-DESC")
#'
#' ## Remove them all at once, specified in different ways
#' drive_rm(x1, "def-DESC", as_id(x2))
#' }
drive_rm <- function(..., verbose = TRUE) {
  dots <- list(...)
  if (length(dots) == 0) {
    if (verbose) message("Nothing to delete.")
    return(invisible(logical(0)))
  }

  ## explicitly select on var name to exclude 'path', if present
  file <- purrr::map(dots, ~ as_dribble(.x)[c("name", "id", "drive_resource")])
  file <- do.call(rbind, file)

  if (verbose) message("No such file(s) to delete.")

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
