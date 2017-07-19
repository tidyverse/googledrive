#' Update a file on Drive with new content.
#'
#' @param file Character, path to the local file to upload.
#' @template path
#' @param ... Query parameters to pass along to the API query.
#' @template verbose
#'
#' @template dribble-return
#' @export
#'
#' @examples
#' \dontrun{
#' ## Upload a file to update.
#' x <- drive_upload(R.home("doc/NEWS"))
#'
#' ## Update the file.
#' x <- drive_update(R.home("doc/NEWS.2"), x)
#'
#' ## clean-up
#' drive_rm(x)
#' }
drive_update <- function(file = NULL,
                         path = NULL,
                         ...,
                         verbose = TRUE) {

  if (!file.exists(file)) {
    stop(glue("File does not exist:\n  * {file}"), call. = FALSE)
  }

  path <- as_dribble(path)
  path <- confirm_some_files(path)

  if (!single_file(path)) {
    paths <- glue_data(path, "  * {name}: {id}")
    stop(
      collapse(c("Path to update is not unique:", paths), sep = "\n"),
         call. = FALSE
      )
  }

  request <- generate_request(
    endpoint = "drive.files.update.media",
    params = list(fileId = path$id,
                  uploadType = "media",
                  fields = "*",
                  ...)
  )

  ## media uploads have unique body situations, so customizing here.
  request$body <- httr::upload_file(path = file)

  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  updated_file <- as_dribble(list(proc_res))
  ## TO DO: this is a pretty weak test for success...
  success <- proc_res$id == updated_file$id[1]

  if (success) {
    if (verbose) {
      message(
        glue("\nFile updated with new media:\n  * {proc_res$name}\n",
             "with id:\n  * {proc_res$id}")
      )
    }
  } else {
    stop("The file doesn't seem to have updated.", call. = FALSE)
  }

  invisible(updated_file)
}
