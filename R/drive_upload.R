#' Upload a file to Google Drive.
#'
#' @seealso MIME types that can be converted to native Google formats:
#'    * <https://developers.google.com/drive/v3/web/manage-uploads#importing_to_google_docs_types_wzxhzdk18wzxhzdk19>
#'
#' @param from Character, local path to the file to upload.
#' @param name Character, name the file should have on Google Drive. Will
#'   default to its local name.
#' @template path
#' @param overwrite A logical scalar, do you want to overwrite a file already on
#'   Google Drive, if such exists?
#' @param type Character. If type = `NULL`, a MIME type is automatically
#'   determined from the file extension, if possible. If the source file is of a
#'   suitable type, you can request conversion to Google Doc, Sheet or Slides by
#'   setting `type` to `document`, `spreadsheet`, or `presentation`,
#'   respectively. All non-`NULL` values for `type`` are pre-processed with
#'   [drive_mime_type()].
#' @template verbose
#'
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' write.csv(chickwts, "chickwts.csv")
#' drive_chickwts <- drive_upload("chickwts.csv")
#'
#' ## or convert it to a Google Sheet
#' drive_chickwts <- drive_upload("chickwts.csv", type = "spreadsheet")
#' }
drive_upload <- function(from = NULL,
                         name = NULL,
                         path = NULL,
                         overwrite = FALSE,
                         type = NULL,
                         verbose = TRUE) {

  if (!file.exists(from)) {
    stop(glue("File does not exist:\n{from}"), call. = FALSE)
  }

  ## upload meta-data:
  ##   * name
  ##   * mimeType
  ##   * parent
  ##   * id

  name <- name %||% basename(from)

  mimeType <- if (is.null(type)) NULL else drive_mime_type(type)

  ## parent folder
  ## TO DO: be willing to create the bits of folder that don't yet exist
  ## for now, user must make sure folder already exists and is unique
  folder <- path %||% root_folder()
  if (is.character(folder)) {
    folder <- append_slash(folder)
  }
  up_parent <- as_dribble(folder)
  up_parent <- confirm_single_file(up_parent)
  if (!is_folder(up_parent)) {
    stop(
      glue_data(up_parent, "'folder' is not a folder:\n{name}"),
      call. = FALSE
    )
  }
  up_parent_id <- up_parent$id

  ## is there a pre-existing file at destination?
  q_name <- glue("name = {sq(name)}")
  q_parent <- glue("{sq(up_parent_id)} in parents")
  qq <- collapse(c(q_name, q_parent), sep = " and ")
  existing <- drive_search(q = qq)

  if (nrow(existing) > 0) {
    out_path <- unsplit_path(up_parent$name %||% "", name)
    if (!overwrite) {
      stop(glue("Path already exists:\n{out_path}", call. = FALSE))
    }
    if (nrow(existing) > 1) {
      stop(glue("Path to overwrite is not unique:\n{out_path}", call. = FALSE))
    }
  }
  ## id for the uploaded file
  up_id <- existing$id

  if (length(up_id) == 0) {
    request <- generate_request(
      endpoint = "drive.files.create",
      params = list(
        name = name,
        parents = list(up_parent_id),
        mimeType = mimeType
      )
    )

    response <- make_request(request, encode = "json")
    proc_res <- process_response(response)
    up_id <- proc_res$id
  }

  request <- generate_request(endpoint = "drive.files.update.media",
                              params = list(fileId = up_id,
                                            uploadType = "media",
                                            fields = "*")
  )

  ## media uploads have unique body situations, so customizing here.
  request$body <- httr::upload_file(path = from,
                                    type = mimeType)

  response <- make_request(request, encode = "json")
  proc_res <- process_response(response)

  uploaded_doc <- as_dribble(list(proc_res))
  ## TO DO: this is a pretty weak test for success...
  success <- proc_res$id == uploaded_doc$id[1]

  if (success) {
    if (verbose) {
      message(
        glue("File uploaded to Google Drive:\n{proc_res$name}\n",
             "with MIME type:\n{proc_res$mimeType}")
      )
    }
  } else {
    spf("Zoinks! the file doesn't seem to have uploaded")
  }

  invisible(uploaded_doc)
}
