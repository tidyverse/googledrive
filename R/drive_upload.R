#' Upload a file to Google Drive
#'
#' @param from character, local path to the file to upload
#' @param up_name character, name the file should have on Google Drive. Will
#'   default to its local name.
#' @param up_folder character, name of parent folder on Google Drive. Will
#'   default to user's root folder, i.e. the top-level of "My Drive".
#' @param overwrite logical, do you want to overwrite file already on Google
#'   Drive
#' @param type if type = `NULL`, will upload as a non-Google Drive document
#'   otherwise you can specify `document`, `spreadsheet`, or `presentation`.
#'   Files with no extension will be assumed to be a `folder`.
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#' @return object of class `gfile` and `list` that contains uploaded file's
#'   information
#' @export
drive_upload <- function(from = NULL,
                         up_name = NULL,
                         up_folder = NULL,
                         overwrite = FALSE,
                         type = NULL,
                         verbose = TRUE) {

  if (!file.exists(from)) {
    stop(glue::glue("File does not exist:\n{from}"), call. = FALSE)
  }

  ## upload elements:
  ##   * name
  ##   * mimeType
  ##   * parent
  ##   * id

  up_name <- up_name %||% basename(from)
  ## LUCY: is it actually important to strip file extension?
  ## earlier version had this:
  # if (!is.null(type)) {
  #   up_name <- tools::file_path_sans_ext(up_name)
  # }

  ## mimeType
  if (!is.null(type) &&
      type %in% c("document", "spreadsheet", "presentation", "folder")) {
    type <- paste0("application/vnd.google-apps.", type)
  }
  mimeType <- type
  ## TO REVISIT: this is quite naive! assumes mimeType is sensible
  ## use mimeType helpers as soon as they exist
  ## maybe add back logic re: getting mimeType from file extension?
  ## the whole issue of upload vs "upload & convert" still needs thought

  ## id of the parent folder
  if (is.null(up_folder)) {
    up_parent_id <- 'root'
  } else {
    ## TO DO: be willing to create the bits of up_folder that don't yet exist
    ## for now, user must make sure up_folder already exists and is unique
    up_parent_id <- get_one_path(path = up_folder)
  }

  ## is there a pre-existing file at destination?
  q_name <- glue::glue("name = {sq(up_name)}")
  q_parent <- glue::glue("{sq(up_parent_id)} in parents")
  qq <- glue::collapse(c(q_name, q_parent), sep = " and ")
  existing <- drive_search(q = qq)

  if (nrow(existing) > 0) {
    out_path <- unsplit_path(up_folder %||% "", up_name)
    if (!overwrite) {
      stop(glue::glue("Path already exists:\n{out_path}", call. = FALSE))
    }
    if (nrow(existing) > 1) {
      stop(glue::glue("Path to overwrite is not unique:\n{out_path}", call. = FALSE))
    }
  }
  ## id for the uploaded file
  up_id <- existing$id

  ## TO DO: build the actual requests
  if (length(up_id) == 0) {
    ## create a file
    ## name = up_name
    ## parents = list(up_parent_id)
    ## mimeType = mimeType
  } else {
    ## update existing file
    ## fileId = up_id
  }

  response <- make_request(request, encode = "json")
  process_drive_upload(response = response,
                       from = from,
                       verbose = verbose)

}

process_drive_upload <- function(response = NULL,
                                 from = NULL,
                                 verbose = TRUE) {
  proc_res <- process_response(response)

  uploaded_doc <- drive_file(proc_res$id)
  success <- proc_res$id == uploaded_doc$id[1]

  if (success) {
    if (verbose) {
      message(
        sprintf(
          "File uploaded to Google Drive: \n%s \nAs the Google %s named:\n%s",
          from,
          sub(".*\\.", "", proc_res$mimeType),
          proc_res$name
        )
      )
    }
  } else {
    spf("Zoinks! the file doesn't seem to have uploaded")
  }

  invisible(uploaded_doc)
}
