#' Trash file on Google Drive.
#'
#' @template file
#' @template verbose
#'
#' @return Logical, indicating whether the trashing succeeded.
#' @export
#' @examples
#' \dontrun{
#' ## Trash a single file in the trash.
#' drive_trash("chickwts.csv")
#'
#' ## Trash multiple files in trash.
#' drive_trash(c("abc", "def"))
#' }
drive_trash <- function(file = NULL, verbose = TRUE) {
  trash_file <- as_dribble(file)
  if (!some_files(trash_file) && verbose) {
    message(glue("No such files found to trash"))
  }

  out <- purrr::map_lgl(trash_file$id, trash_one)

  if (verbose) {
    if (any(out)) {
      successes <- glue_data(trash_file[out, ], "  * {name}: {id}")
      message(collapse(c("Files trashed:", successes), sep = "\n"))
    }
    if (any(!out)) {
      failures <- glue_data(trash_file[!out, ], "  * {name}: {id}")
      message(collapse(c("Files NOT trashed:", failures), sep = "\n"))
    }
  }
  invisible(out)
}

trash_one <- function(id, trash = TRUE) {
  request <- generate_request(
    endpoint = "drive.files.update",
    params = list(fileId = id,
                  trashed = trash)
  )
  proc_res <- do_request(request, encode = "json")
  identical(proc_res$id, id)
}

#' Untrash file on Google Drive.
#'
#' @template file
#' @template verbose
#'
#' @return Logical, indicating whether the untrashing succeeded.
#' @export
#'
#' @examples
#' \dontrun{
#' ## Untrash a single file in the trash.
#' drive_untrash("chickwts.csv")
#'
#' ## Untrash multiple files in trash.
#' drive_untrash(c("abc", "def"))
#' }
drive_untrash <- function(file = NULL, verbose = TRUE) {
  if (is.character(file)) {
    file <- drive_search(file, q = "trashed = true")
  }
  trash_file <- as_dribble(file)
  if (!some_files(trash_file) && verbose) {
    message(glue("No such files found to trash"))
  }

  out <- purrr::map_lgl(trash_file$id, trash_one, trash = FALSE)

  if (verbose) {
    if (any(out)) {
      successes <- glue_data(trash_file[out, ], "  * {name}: {id}")
      message(collapse(c("Files untrashed:", successes), sep = "\n"))
    }
    if (any(!out)) {
      failures <- glue_data(trash_file[!out, ], "  * {name}: {id}")
      message(collapse(c("Files NOT untrashed:", failures), sep = "\n"))
    }
  }
  invisible(out)
}

#' View files in Google Drive Trash.
#' @export
drive_view_trash <- function() {
  drive_search(q = "trashed = true")
}

#' Empty Google Drive Trash.
#'
#' @template verbose
#' @template dribble-return
#' @description Caution: this will permanently delete files in your
#'    Google Drive trash.
#' @export
drive_empty_trash <- function(verbose = TRUE) {
  files <- drive_view_trash()
  del <- drive_delete(files, verbose = FALSE)
  n <- sum(del)
  if (verbose) {
    if (n > 0L) {
    message(glue("You have successfully deleted {n} files from your Google Drive trash."))
    } else {
      message("Your trash was already empty.")
    }
  }
}
