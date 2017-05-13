#' Move Google Drive file
#'
#' @param file `gfile` object for the file you would like to move
#' @param folder `gfile` object for the folder you would like to move the
#'   file to
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#' @return `gfile` that was moved
#' @export
drive_mv <- function(file = NULL,
                     folder = NULL,
                     verbose = TRUE) {
  request <- build_drive_mv(file = file, folder = folder)
  response <- make_request(request)
  proc_res <-
    process_drive_mv(
      response = response,
      file = file,
      folder = folder,
      verbose = verbose
    )

  file <- drive_file(proc_res$id)
  invisible(file)
}

build_drive_mv <-
  function(file = NULL,
           folder = NULL,
           token = drive_token()) {
    if (!inherits(file, "gfile")) {
      spf("Input `file` must be a `gfile`. See `drive_file()`")
    }

    if (!inherits(folder, "gfile")) {
      spf("Input `folder` must be a `gfile`. See `drive_file()`")
    }

    url <- file.path(
      .state$drive_base_url_files_v3,
      paste0(
        file$id,
        "?addParents=",
        folder$id,
        "&removeParents=",
        file$kitchen_sink$parents[[1]]
      )
    )

    build_request(endpoint = url,
                  token = token,
                  method = "PATCH")
  }

process_drive_mv <-
  function(response = NULL,
           file = NULL,
           folder = NULL,
           verbose = TRUE) {
    proc_res <- process_request(response)
    if (verbose) {
      if (response$status_code == 200L) {
        message(
          sprintf(
            "The Google Drive file:\n%s \nwas moved to folder:\n%s",
            file$name,
            folder$name
          )
        )
      } else
        spf("Oh dear! Something went wrong, the file '%s' was not moved",
            file$name)
    }
    proc_res
  }
