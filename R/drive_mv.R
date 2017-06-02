#' Move Google Drive file
#'
#' @template file
#' @param folder Drive Folder, something that identifies the folder of interest
#'   on your Google Drive. This can be name(s)/path(s), marked folder id(s),
#'   or a \code{dribble}.
#' @template verbose
#'
#' @template dribble-return
#' @export
drive_mv <- function(file = NULL,
                     folder = NULL,
                     verbose = TRUE) {
  file <- as_dribble(file)
  folder <- as_dribble(folder)

  if (nrow(file) != 1 || nrow(folder) != 1) {
    stop("We can currently only move 1 Drive File at a time.")
  }

  if (!is_owner(file)) {
    stop(
      glue::glue_data(
        file,
        "You are trying to move file: {id} \nYou do not own this file"
      )
    )
  }
  if (!is_folder(folder)) {
    stop(
      glue::glue_data(
        folder,
        "The folder you have input, id: {id} \nis not a valid Google Drive folder."
        )
    )
  }

  request <- build_request(
    endpoint = "drive.files.update.meta",
    params = list(
      fileId = file$id,
      addParents = folder$id,
      removeParents = file$files_resource[[1]]$parents
    )
  )

  response <- make_request(request)
  proc_res <- process_response(response)

  if (verbose) {
    if (response$status_code == 200L) {
      message(
        glue::glue(
          "The Google Drive file:\n{file$name} \nwas moved to folder:\n{folder$name}"
        )
      )
    } else {
      message(
        glue::glue_data(
          file,
          "Oh dear! Something went wrong, the file '{name}' was not moved"
        )
      )
    }
  }

  file <- as_dribble(drive_id(proc_res$id))
  invisible(file)
}
