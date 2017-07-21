#' Move files to or from trash.
#' @template file
#' @template verbose
#'
#' @template dribble-return
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
drive_trash <- function(file, verbose = TRUE) {
  invisible(drive_toggle_trash(file, trash = TRUE, verbose = verbose))
}

#' @rdname drive_trash
#' @export
drive_untrash <- function(file, verbose = TRUE) {
  if (is_path(file)) {
    trash <- drive_view_trash()
    file <- trash[trash$name %in% file, ]
  }
  invisible(drive_toggle_trash(file, trash = FALSE, verbose = verbose))
}

drive_toggle_trash <- function(file, trash, verbose = TRUE) {
  VERB <- if (trash) "trash" else "untrash"
  VERBED <- paste0(VERB, "ed")

  file <- as_dribble(file)
  if (no_file(file)) {
    if (verbose) mglue("No such files found to {VERB}.")
    return(invisible(dribble()))
  }

  out <- purrr::map(file$id, toggle_trash_one, trash = trash)
  out <- do.call(rbind, out)

  if (verbose) {
    files <- glue::glue_data(out, "  * {name}: {id}")
    mcollapse(c(glue::glue("Files {VERBED}:"), files), sep = "\n")
  }
  invisible(out)
}

toggle_trash_one <- function(id, trash = TRUE) {
  request <- generate_request(
    endpoint = "drive.files.update",
    params = list(fileId = id,
                  trashed = trash,
                  fields = "*")
  )
  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)
  as_dribble(list(proc_res))
}

#' Get files in Drive Trash.
#' @template dribble-return
#' @export
drive_view_trash <- function() {
  drive_find(q = "trashed = true")
}

#' Empty Drive Trash.
#'
#' @description Caution, this will permanently delete files in your Drive trash.
#'
#' @template verbose
#' @export
drive_empty_trash <- function(verbose = TRUE) {
  files <- drive_view_trash()
  if (no_file(files)) {
    if (verbose) message("Your trash was already empty.")
    return(invisible(TRUE))
  }
  del <- drive_rm(files, verbose = FALSE)
  if (verbose) {
    mglue(
      "{sum(del)} file(s) deleted from your Google Drive trash."
    )
  }
  return(invisible(TRUE))
}
