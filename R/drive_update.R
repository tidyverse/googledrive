#' Update an existing Drive file
#'
#' @seealso Wraps the
#' [drive.files.update](https://developers.google.com/drive/v3/reference/files/update)
#' endpoint. In particular, does [media upload](https://developers.google.com/drive/v3/web/manage-uploads).
#'
#' @template file
#' @template media
#' @param ... Parameters to pass along to the API query. NOT IMPLEMENTED YET.
#' @template verbose
#'
#' @template dribble-return
#' @export
#'
#' @examples
#' \dontrun{
#' ## Create a new file, so we can update it.
#' x <- drive_upload(R.home("doc/NEWS"))
#'
#' ## Update the file with new content.
#' x <- x %>%
#'   drive_update(R.home("doc/NEWS.2"))
#'
#' ## clean-up
#' drive_rm(x)
#' }
drive_update <- function(file = NULL,
                         media = NULL,
                         ...,
                         verbose = TRUE) {

  if (!file.exists(media)) {
    stop(glue("\nLocal file does not exist:\n  * {media}"), call. = FALSE)
  }

  file <- as_dribble(file)
  file <- confirm_some_files(file)

  if (!single_file(file)) {
    files <- glue_data(file, "  * {name}: {id}")
    stop(
      collapse(c("Path to update is not unique:", files), sep = "\n"),
      call. = FALSE
    )
  }

  request <- generate_request(
    endpoint = "drive.files.update.media",
    params = list(fileId = file$id,
                  uploadType = "media",
                  fields = "*",
                  ...)
  )

  ## media uploads have unique body situations, so customizing here.
  request$body <- httr::upload_file(path = media)

  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  out <- as_dribble(list(proc_res))

  if (verbose) {
    message(glue("\nFile updated:\n  * {out$name}: {out$id}"))
  }
  invisible(out)
}
