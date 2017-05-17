#' Make a Google Drive Directory
#'
#' @param dir character, name of the folder you would like to create
#' @param path character, path where you would like the folder on your Google Drive
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#' @return object of class `gfile` and `list` that contains uploaded folder's
#'   information
#' @export
drive_mkdir <- function(dir = NULL, path = NULL, verbose = TRUE) {
  parent <- NULL

  if (!is.null(path)) {
    parent <- get_parent(path = path)
  }

  request <- build_request(
    method = "create",
    token = drive_token(),
    params = list(
      name = dir,
      mimeType =  "application/vnd.google-apps.folder",
      parents = list(parent)
    )
  )

  response <- make_request(request, encode = "json")
  proc_res <- process_request(response)

  folder <- drive_file(proc_res$id)

  success <- folder$name == dir
  if (verbose) {
    if (success) {
      message(sprintf(
        "You have successfully uploaded the folder: '%s'.",
        proc_res$name
      ))
    } else
      message(
        sprintf(
          "Uh oh, something went wrong. The folder '%s' was no uploaded.",
          proc_res$name
        )
      )
  }
  invisible(drive_file(proc_res$id))
}

get_parent <- function(path) {
  path_pieces <- unlist(strsplit(path, "/"))

  root_id <- root_folder()

  if (all(path_pieces == "~")) {
    return(root_id)
  }

  if (path_pieces[1] == "~") {
    path_pieces <- path_pieces[-1]
  }

  d <- length(path_pieces)

  leafmost <- path_pieces[d]
  upper_folders <- "~"

  if (d > 1) {
    upper_folders <- paste(path_pieces[seq_len(d - 1)],
                           collapse = "/")
  }
  leafmost_tbl <- drive_list(path = upper_folders,
                             pattern = paste0("^", leafmost, "$"))

  if (nrow(leafmost_tbl) != 1) {
    spf(
      "We could not find a unique folder named '%s' in the path '%s' on your Google Drive.",
      leafmost,
      upper_folders
    )
  }

  leafmost_tbl$id
}
