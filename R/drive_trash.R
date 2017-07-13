#' Move Drive files to the trash.
#' @template file
#' @template verbose
#'
#' @return Logical vector, indicating whether the trashing/untrashing succeeded.
#' @export
#' @examples
#' \dontrun{
#' ## Create a file to trash.
#' file <- drive_upload(system.file("DESCRIPTION"), "DESC")
#' ## Put a single file in the trash.
#' drive_trash("DESC")
#' drive_untrash("DESC")
#'
#' ## Put multiple files in trash.
#' file_a <- drive_upload(system.file("DESCRIPTION"), "file_a")
#' file_b <- drive_upload(system.file("DESCRIPTION"), "file_b")
#' drive_trash(c("file_a", "file_b"))
#' drive_untrash(c("file_a", "file_b"))
#' }
drive_trash <- function(file = NULL, verbose = TRUE) {
  trash_file <- as_dribble(file)
  if (no_file(trash_file) && verbose) {
    message(glue("No such files found to trash"))
    return(invisible(logical(0)))
  }

  out <- purrr::map_lgl(trash_file$id, toggle_trash_one)

  if (verbose) {
    if (any(out)) {
      successes <- glue_data(trash_file[out, ], "  * {name}: {id}")
      message(collapse(c("Files trashed:", successes), sep = "\n"))
    }
  }
  invisible(out)
}

toggle_trash_one <- function(id, trash = TRUE) {
  request <- generate_request(
    endpoint = "drive.files.update",
    params = list(fileId = id,
                  trashed = trash)
  )
  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)
  identical(proc_res$id, id)
}

#' @rdname drive_trash
#' @export
drive_untrash <- function(file = NULL, verbose = TRUE) {
  if (is_path(file)) {
    paths <- collapse(file, sep = "|")
    ## TODO this won't take file paths like a/b/c :(
    file <- drive_find(paths, q = "trashed = true")
  }
  trash_file <- as_dribble(file)
  if (no_file(trash_file) && verbose) {
    message(glue("No such files found to trash"))
    return(invisible(logical(0)))
  }

  out <- purrr::map_lgl(trash_file$id, toggle_trash_one, trash = FALSE)

  if (verbose) {
    if (any(out)) {
      successes <- glue_data(trash_file[out, ], "  * {name}: {id}")
      message(collapse(c("Files untrashed:", successes), sep = "\n"))
    }
  }
  invisible(out)
}

#' View files in Drive Trash.
#' @template dribble-return
#' @export
drive_view_trash <- function() {
  drive_find(q = "trashed = true")
}

#' Empty Drive Trash.
#' Caution: this will permanently delete files in your Drive trash.
#' @template verbose
#' @export
drive_empty_trash <- function(verbose = TRUE) {
  files <- drive_view_trash()
  n <- nrow(files)
  if (n == 0L) {
    message("Your trash was already empty.")
    return(invisible(logical(0)))
  }
  del <- drive_rm(files, verbose = FALSE)
  if (verbose) {
    message(glue("You have successfully deleted {n} file(s) from your Google Drive trash."))
    return(invisible(TRUE))
  }
}
