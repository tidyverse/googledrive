#' Move Drive files to or from trash
#' @template file-plural
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' # Create a file and put it in the trash.
#' file <- drive_upload(drive_example("chicken.txt"), "chicken-trash.txt")
#' drive_trash("chicken-trash.txt")
#'
#' # Confirm it's in the trash
#' drive_find(trashed = TRUE)
#'
#' # Remove it from the trash and confirm
#' drive_untrash("chicken-trash.txt")
#' drive_find(trashed = TRUE)
#'
#' # Clean up
#' drive_rm("chicken-trash.txt")
#' }
drive_trash <- function(file, verbose = deprecated()) {
  warn_for_verbose(verbose)
  invisible(drive_toggle_trash(file, trash = TRUE))
}

#' @rdname drive_trash
#' @export
drive_untrash <- function(file, verbose = deprecated()) {
  warn_for_verbose(verbose)
  if (is_path(file)) {
    trash <- drive_find(trashed = TRUE)
    file <- trash[trash$name %in% file, ]
  }
  invisible(drive_toggle_trash(file, trash = FALSE))
}

drive_toggle_trash <- function(file, trash) {
  VERB <- if (trash) "trash" else "untrash"
  VERBED <- paste0(VERB, "ed")

  file <- as_dribble(file)
  if (no_file(file)) {
    drive_bullets(c("!" = "No such files found to {VERB}."))
    return(invisible(dribble()))
  }

  out <- purrr::map(file$id, toggle_trash_one, trash = trash)
  out <- do.call(rbind, out)

  drive_bullets(c(
    "{cli::qty(nrow(out))}File{?s} {VERBED}:",
    cli_format_dribble(out)
  ))

  invisible(out)
}

toggle_trash_one <- function(id, trash = TRUE) {
  request <- request_generate(
    endpoint = "drive.files.update",
    params = list(
      fileId = id,
      trashed = trash,
      fields = "*"
    )
  )
  response <- request_make(request)
  proc_res <- gargle::response_process(response)
  as_dribble(list(proc_res))
}

drive_reveal_trashed <- function(file) {
  confirm_dribble(file)
  if (no_file(file)) {
    return(
      put_column(dribble(), nm = "trashed", val = logical(), .after = "name")
    )
  }
  promote(file, "trashed")
}

#' Empty Drive Trash
#'
#' @description Caution, this will permanently delete files in your Drive trash.
#'
#' @template verbose
#' @export
drive_empty_trash <- function(verbose = deprecated()) {
  warn_for_verbose(verbose)

  files <- drive_find(trashed = TRUE)
  if (no_file(files)) {
    drive_bullets(c(
      "i" = "No files found in trash; your trash was already empty."
    ))
    return(invisible(TRUE))
  }
  request <- request_generate(endpoint = "drive.files.emptyTrash")
  response <- request_make(request)
  success <- gargle::response_process(response)
  if (success) {
    drive_bullets(c(
      "v" = "{nrow(files)} file{?s} deleted from your Google Drive trash."
    ))
  } else {
    drive_bullets(c(
      "x" = "Empty trash appears to have failed."
    ))
  }
  invisible(success)
}
