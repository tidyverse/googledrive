#' Upload a file to Google Drive
#'
#' @param from character, local path to the file to upload
#' @param up_name character, name the file should have on Google Drive. Will
#'   default to its local name.
#' @param up_folder character, name of parent folder on Google Drive. Will
#'   default to user's root folder, i.e. the top-level of "My Drive".
#' @param overwrite logical, do you want to overwrite a file already on Google
#'   Drive, if such exists?
#' @param type character. If type = `NULL`, a MIME type is automatically
#'   determined from the file extension, if possible. If the source file is of a
#'   suitable type, you can request conversion to Google Doc, Sheet or Slides by
#'   setting `type` to `document`, `spreadsheet`, or `presentation`,
#'   respectively.
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#'  MIME types that can be converted to native Google formats:
#'    * <https://developers.google.com/drive/v3/web/manage-uploads#importing_to_google_docs_types_wzxhzdk18wzxhzdk19>
#'
#' @return object of class `dribble` and `tbl` that contains uploaded file's
#'   information
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
                         up_name = NULL,
                         up_folder = NULL,
                         overwrite = FALSE,
                         type = NULL,
                         verbose = TRUE) {

  if (!file.exists(from)) {
    stop(glue::glue("File does not exist:\n{from}"), call. = FALSE)
  }

  ## upload meta-data:
  ##   * name
  ##   * mimeType
  ##   * parent
  ##   * id

  up_name <- up_name %||% basename(from)

  ## mimeType
  if (!is.null(type) &&
      type %in% c("document", "spreadsheet", "presentation", "folder")) {
    type <- paste0("application/vnd.google-apps.", type)
    up_name <- tools::file_path_sans_ext(up_name)
  }
  mimeType <- type
  ## TO REVISIT: this is quite naive! assumes mimeType is sensible
  ## use mimeType helpers as soon as they exist
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

  if (length(up_id) == 0) {
    request <- build_request(
      endpoint = "drive.files.create.meta",
      params = list(
        name = up_name,
        parents = list(up_parent_id),
        mimeType = mimeType
      )
    )

    response <- make_request(request, encode = "json")
    proc_res <- process_response(response)
    up_id <- proc_res$id
  }

  request <- build_request(
    endpoint = "drive.files.update.media",
    params = list(
      fileId = up_id,
      uploadType = "media",
      body = httr::upload_file(path = from,
                               type = mimeType)
    )
  )


  response <- make_request(request, encode = "json")
  process_drive_upload(response = response,
                       from = from,
                       verbose = verbose)

}

process_drive_upload <- function(response = NULL,
                                 from = NULL,
                                 verbose = TRUE) {
  proc_res <- process_response(response)

  uploaded_doc <- drive_get(proc_res$id)
  success <- proc_res$id == uploaded_doc$id[1]

  if (success) {
    if (verbose) {
      message(
        glue::glue("File uploaded to Google Drive:\n{proc_res$name}\n",
                   "with MIME type:\n{proc_res$mimeType}")
      )
    }
  } else {
    spf("Zoinks! the file doesn't seem to have uploaded")
  }

  invisible(uploaded_doc)
}
