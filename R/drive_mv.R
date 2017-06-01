#' Move Google Drive file
#'
#' @template file
#' @param folder object of class `dribble` or `drive_id` for the folder you would like to move the
#'   file to
#' @template verbose
#'
#' @template dribble
#' @export
drive_mv <- function(file = NULL,
                     folder = NULL,
                     verbose = TRUE) {
  file <- as.dribble(file)
  folder <- as.dribble(folder)

  if (nrow(file) != 1 || nrow(folder) != 1) {
    spf("We can currently only move 1 `dribble` at a time.")
  }

  request <- build_request(
    endpoint = "drive.files.update.meta",
    params = list(
      fileId = file$id,
      addParents = folder$id,
      removeParents = file$file_resource[[1]]$parents
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

  file <- drive_get(proc_res$id)
  invisible(file)
}
