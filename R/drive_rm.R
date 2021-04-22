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
#' drive_upload(drive_example("chicken.txt"), name = "chicken-rm.txt")
#'
#' ## Remove it by name
#' drive_rm("chicken-rm.txt")
#'
#' ## Create several things to remove
#' x1 <- drive_upload(drive_example("chicken.txt"), name = "chicken-abc.txt")
#' drive_upload(drive_example("chicken.txt"), name = "chicken-def.txt")
#' x2 <- drive_upload(drive_example("chicken.txt"), name = "chicken-ghi.txt")
#'
#' ## Remove them all at once, specified in different ways
#' drive_rm(x1, "chicken-def.txt", as_id(x2))
#' }
drive_rm <- function(..., verbose = deprecated()) {
  warn_for_verbose(verbose)
  dots <- list(...)
  if (length(dots) == 0) {
    dots <- list(NULL)
  }

  # explicitly select on var name to exclude 'path', if present
  file <- purrr::map(dots, ~as_dribble(.x)[c("name", "id", "drive_resource")])
  file <- exec(rbind, !!!file)
  # filter to the unique file ids (multiple parents mean drive_get() and
  # therefore as_dribble() can return >1 row representing a single file)
  file <- file[!duplicated(file$id), ]

  if (no_file(file)) {
    drive_bullets(c(
      "!" = "No such file to delete."
    ))
  }

  out <- purrr::map_lgl(file$id, delete_one)

  if (any(out)) {
    successes <- file[out, ]
    drive_bullets(c(
      "File{?s} deleted:{cli::qty(nrow(successes))}",
      cli_format_dribble(successes)
    ))
  }
  # I'm not sure this ever comes up IRL?
  # Is it even possible that removal fails but there's no error?
  if (any(!out)) {
    failures <- file[!out, ]
    drive_bullets(c(
      "File{?s} NOT deleted:{cli::qty(nrow(failures))}",
      cli_format_dribble(failures)
    ))
  }
  invisible(out)
}

delete_one <- function(id) {
  request <- request_generate(
    endpoint = "drive.files.delete",
    params = list(fileId = id)
  )
  response <- request_make(request)
  gargle::response_process(response)
}
