#' Move Google Drive file.
#'
#' @template file
#' @template folder
#' @template verbose
#'
#' @template dribble-return
#' @export
drive_mv <- function(file = NULL,
                     folder = NULL,
                     verbose = TRUE) {
  file <- confirm_single_file(as_dribble(file))
  folder <- confirm_single_file(as_dribble(folder))

  if (!is_mine(file)) {
    stop(
      glue::glue_data(
        file,
        "You do not own and, therefore cannot move, this file:\n{name}"
      ),
      call. = FALSE
    )
  }
  if (!is_folder(folder)) {
    stop(
      glue::glue_data(folder, "'folder' is not a folder:\n{name}"),
      call. = FALSE
    )
  }

  request <- build_request(
    endpoint = "drive.files.update.meta",
    params = list(
      fileId = file$id,
      addParents = folder$id,
      removeParents = file$files_resource[[1]]$parents,
      fields = "*"
    )
  )

  response <- make_request(request)
  proc_res <- process_response(response)

  if (verbose) {
    if (httr::status_code(response) == 200L) {
      message(
        glue::glue(
          "This file:\n{file$name}\nwas moved to folder:\n{folder$name}"
        )
      )
    } else {
      message(
        glue::glue_data(file, "Oh dear! this file was not moved:\n{name}")
      )
    }
  }

  file <- as_dribble(list(proc_res))
  invisible(file)
}
