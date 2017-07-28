#' Update an existing Drive file
#'
#' @seealso Wraps the
#' [drive.files.update](https://developers.google.com/drive/v3/reference/files/update)
#' endpoint. In particular, does [media upload](https://developers.google.com/drive/v3/web/manage-uploads).
#'
#' @template file
#' @template media
#' @template dots
#' @template verbose
#'
#' @template dribble-return
#' @export
#'
#' @examples
#' \dontrun{
#' ## Create a new file, so we can update it
#' x <- drive_upload(R.home("doc/NEWS"))
#'
#' ## Update the file with new media
#' x <- x %>%
#'   drive_update(R.home("doc/NEWS.1"))
#'
#' ## Update the file with new metadata.
#' ## Notice here `name` is not a parameter, we are passing
#' ## this through the ...
#' x <- x %>%
#'   drive_update(name = "NEWS-1")
#'
#' ## Update the file with new media AND new metadata
#' x <- x %>%
#'   drive_update(R.home("doc/NEWS.2"), name = "NEWS-2")
#'
#' ## Clean up
#' drive_rm(x)
#' }
drive_update <- function(file,
                         media = NULL,
                         ...,
                         verbose = TRUE) {

  file <- as_dribble(file)
  file <- confirm_some_files(file)

  if (!single_file(file)) {
    files <- glue_data(file, "  * {name}: {id}")
    stop_collapse(c("Path to update is not unique:", files))
  }

  if (!is_mine(file)) {
    stop_glue("\nCan't update this file because you don't own it:\n  * {file$name}")
  }

  params <- list(
    fileId = file$id,
    fields = "*",
    ...)

  if (identical(names(params), c("fileId", "fields"))) {
    response <- drive_update_media(file = file, media = media)
  } else if (is.null(media)) {
    response <- drive_update_metadata(params)
  } else {
    response <- drive_update_multipart(file = file, media = media, ...)
  }

  proc_res <- process_response(response)

  out <- as_dribble(list(proc_res))

  if (verbose) {
    message_glue("\nFile updated:\n  * {out$name}: {out$id}")
  }

  invisible(out)
}


drive_update_media <- function(file, media) {
  if (!file.exists(media)) {
    stop_glue("\nLocal file does not exist:\n  * {media}")
  }
  request <- generate_request(
    endpoint = "drive.files.update.media",
    params = list(fileId = file$id,
                  uploadType = "media",
                  fields = "*"
    )
  )

  ## media uploads have unique body situations, so customizing here.
  request$body <- httr::upload_file(path = media)
  make_request(request, encode = "json")
}

drive_update_metadata <- function(params) {
  request <- generate_request(
    endpoint = "drive.files.update",
    params = params
  )
  make_request(request, encode = "json")
}

drive_update_multipart <- function(file, media, ...) {

  if (!file.exists(media)) {
    stop_glue("\nLocal file does not exist:\n  * {media}")
  }
  request <- generate_request(
    endpoint = "drive.files.update.media",
    params = list(fileId = file$id,
                  uploadType = "multipart",
                  fields = "*",
                  ## We are putting this (...) here even though they will be overwritten
                  ## because our generate_request() function vets the input parameters
                  ## for this endpoint.
                  ...

    )
  )
  metadata <- tempfile()
  writeLines(jsonlite::toJSON(list(...)), metadata)
  ## media uploads have unique body situations, so customizing here.
  request$body <- list(
    metadata = httr::upload_file(path = metadata, type = "application/json; charset=UTF-8"),
    media = httr::upload_file(path = media)
  )
  response <- make_request(request)
  unlink(metadata)
  response
}
