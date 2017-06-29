#' Move Google Drive file.
#'
#' @description [`drive_move()`] is an alias for [`drive_mv()`].
#' @template file
#' @param name Character, name you would like the moved file to have. Will
#'    default to its current name.
#' @template path
#' @template verbose
#'
#' @template dribble-return
#' @export
drive_mv <- function(file = NULL, name = NULL, path = NULL, verbose = TRUE) {
  file <- as_dribble(file)
  file <- confirm_single_file(file)

  name <- name %||% file$name

  if (!is_mine(file)) {
    stop(
      glue_data(
        file,
        "You do not own and, therefore cannot move, this file:\n{name}"
      ),
      call. = FALSE
    )
  }

  folder_name <- NULL
  if (!is.null(path)) {
    folder <- as_dribble(path)
    folder <- confirm_single_file(folder)
    folder_name <- paste0(folder$name, "/")
    if (!is_folder(folder)) {
      stop(
        glue_data(folder, "'folder' is not a folder:\n{name}"),
        call. = FALSE
      )
    }

    request <- generate_request(
      endpoint = "drive.files.update",
      params = list(
        fileId = file$id,
        name = name,
        addParents = folder$id,
        removeParents = file$files_resource[[1]]$parents,
        fields = "*"
      )
    )
  } else {
    request <- generate_request(
      endpoint = "drive.files.update",
      params = list(
        fileId = file$id,
        name = name,
        fields = "*"
      )
    )
  }

  proc_res <- do_request(request, encode = "json")

  if (verbose) {
    if (proc_res$name == name) {
      message(glue("File moved: \n  * {file$name} -> {paste0(folder_name, name)}"))
    } else {
      message(glue("File NOT moved: \n * {file$name}"))
    }
  }

  file <- as_dribble(list(proc_res))
  invisible(file)
}

#' @rdname drive_mv
#' @export
drive_move <- drive_mv
