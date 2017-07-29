#' Update an existing Drive file
#'
#' TO DO: document me with more words.
#'
#' @seealso Wraps the
#' [drive.files.update](https://developers.google.com/drive/v3/reference/files/update)
#' endpoint. In particular, does [media upload](https://developers.google.com/drive/v3/web/manage-uploads).
#'
#' @template file
#' @template media
#' @template dots-metadata
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
#' ## Notice here `name` is not a parameter in `drive_update()`, we are passing
#' ## this to the API via the `...``
#' x <- x %>%
#'   drive_update(name = "NEWS-1")
#'
#' ## We can also add additional parent folders by passing `addParents` to the `...`.
#' ## This will mean the file now will exist in two folders.
#' ## First create a folder "new-folder" to place the file `x` in.
#' folder <- drive_mkdir("new-folder")
#' ## Add the parent to the file `x`.
#' x <- x %>%
#'   drive_update(addParents = folder$id)
#'
#' ## Verify the file now has multiple parents
#' x$files_resource[[1]]$parents
#'
#' ## Update the file with new media AND new metadata
#' x <- x %>%
#'   drive_update(R.home("doc/NEWS.2"), name = "NEWS-2")
#'
#' ## Clean up
#' drive_rm(x)
#' drive_rm(folder)
#' }
drive_update <- function(file,
                         media = NULL,
                         ...,
                         verbose = TRUE) {

  file <- as_dribble(file)
  file <- confirm_some_files(file)

  if (!single_file(file)) {
    files <- glue_data(file, "  * {name}: {id}")
    stop_collapse(c("File to update is not unique:", files))
  }

  if (!is_mine(file)) {
    stop_glue("\nCan't update this file because you don't own it:\n  * {file$name}")
  }

  if (!is.null(media) && !file.exists(media)) {
    stop_glue("\nLocal file does not exist:\n  * {media}")
  }
  meta <- list(...)
  ## TO DO: what if user puts fields in `...`?
  ## we deal with that in drive_find() FWIW, but I'm not sure it's best way

  if (is.null(media)) {
    if (length(meta) == 0) {
      if (verbose) message("No updates specified.")
    } else {
      out <- drive_update_metadata(file, meta)
    }
  } else {
    if (length(meta) == 0) {
      out <- drive_update_media(file, media)
    } else {
      out <- drive_update_multipart(file, media, meta)
    }
  }

  if (verbose) {
    message_glue("\nFile updated:\n  * {out$name}: {out$id}")
  }

  invisible(out)
}


drive_update_media <- function(file, media) {
  request <- generate_request(
    endpoint = "drive.files.update.media",
    params = list(
      fileId = file$id,
      uploadType = "media",
      fields = "*"
    )
  )

  ## media uploads have unique body situations, so customizing here.
  request$body <- httr::upload_file(path = media)
  response <- make_request(request, encode = "json")
  as_dribble(list(process_response(response)))
}

drive_update_metadata <- function(file, meta) {
  request <- generate_request(
    endpoint = "drive.files.update",
    params = c(
      fileId = file$id,
      fields = "*",
      meta
    )
  )
  response <- make_request(request, encode = "json")
  as_dribble(list(process_response(response)))
}

drive_update_multipart <- function(file, media, meta) {
  request <- generate_request(
    endpoint = "drive.files.update.media",
    params = c(
      fileId = file$id,
      uploadType = "multipart",
      fields = "*",
      ## We provide the metadata here even though it's overwritten below,
      ## so that generate_request() still validates it.
      meta
    )
  )
  meta_file <- tempfile()
  on.exit(unlink(meta_file))
  writeLines(jsonlite::toJSON(meta), meta_file)
  ## media uploads have unique body situations, so customizing here.
  request$body <- list(
    metadata = httr::upload_file(
      path = meta_file,
      type = "application/json; charset=UTF-8"
    ),
    media = httr::upload_file(path = media)
  )
  response <- make_request(request)
  as_dribble(list(process_response(response)))
}
