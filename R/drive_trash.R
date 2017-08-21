#' Move files to or from trash
#' @template file-plural
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## Create a file and put it in the trash.
#' file <- drive_upload(system.file("DESCRIPTION"), "DESC-trash-ex")
#' drive_trash("DESC-trash-ex")
#'
#' ## Confirm it's in the trash
#' drive_find(trashed = TRUE)
#'
#' ## Remove it from the trash and confirm
#' drive_untrash("DESC-trash-ex")
#' drive_find(trashed = TRUE)
#'
#' ## Clean up
#' drive_rm("DESC-trash-ex")
#' }
drive_trash <- function(file, verbose = TRUE) {
  invisible(drive_toggle_trash(file, trash = TRUE, verbose = verbose))
}

#' @rdname drive_trash
#' @export
drive_untrash <- function(file, verbose = TRUE) {
  if (is_path(file)) {
    trash <- drive_find(trashed = TRUE)
    file <- trash[trash$name %in% file, ]
  }
  invisible(drive_toggle_trash(file, trash = FALSE, verbose = verbose))
}

drive_toggle_trash <- function(file, trash, verbose = TRUE) {
  VERB <- if (trash) "trash" else "untrash"
  VERBED <- paste0(VERB, "ed")

  file <- as_dribble(file)
  if (no_file(file)) {
    if (verbose) message_glue("No such files found to {VERB}.")
    return(invisible(dribble()))
  }

  out <- purrr::map(file$id, toggle_trash_one, trash = trash)
  out <- do.call(rbind, out)

  if (verbose) {
    files <- glue_data(out, "  * {name}: {id}")
    message_collapse(c(glue("Files {VERBED}:"), files))
  }
  invisible(out)
}

toggle_trash_one <- function(id, trash = TRUE) {
  request <- generate_request(
    endpoint = "drive.files.update",
    params = list(
      fileId = id,
      trashed = trash,
      fields = "*")
  )
  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)
  as_dribble(list(proc_res))
}

drive_reveal_trashed <- function(file) {
  confirm_dribble(file)
  if (no_file(file)) {
    return(put_column(dribble(), trashed = logical(), .after = "name"))
  }
  promote(file, "trashed")
}

#' Empty Drive Trash
#'
#' @description Caution, this will permanently delete files in your Drive trash.
#'
#' @template verbose
#' @export
drive_empty_trash <- function(verbose = TRUE) {
  files <- drive_find(trashed = TRUE)
  if (no_file(files)) {
    if (verbose) message("Your trash was already empty.")
    return(invisible(TRUE))
  }
  del <- drive_rm(files, verbose = FALSE)
  if (verbose) {
    message_glue(
      "{sum(del)} file(s) deleted from your Google Drive trash."
    )
  }
  return(invisible(TRUE))
}
