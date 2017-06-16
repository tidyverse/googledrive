#' Search for files on Google Drive.
#'
#'   This will default to the most recent 100 files on your Google Drive. For
#'   example, to get 200 instead, specify the `pageSize`, i.e.
#'   `drive_ls(pageSize = 200)`.

#' @seealso Helpful links for forming queries:
#'   * <https://developers.google.com/drive/v3/web/search-parameters>
#'   * <https://developers.google.com/drive/v3/reference/files/list>
#'
#' @param pattern Character. If provided, only the files whose names match this
#'   regular expression are returned.
#' @param type Character. If provided, only files of this type will be returned.
#'   Can be anything that [drive_mime_type()] knows how to handle.
#' @param ... Parameters to pass along to the API query.
#' @template verbose
#'
#' @template dribble-return
#' @examples
#' \dontrun{
#' ## list "My Drive" w/o regard for folder hierarchy
#' drive_search()
#'
#' ## search for files located directly in your root folder
#' drive_search(q = "'root' in parents")
#'
#' ## filter for folders
#' drive_search(type = "folder")
#' drive_search(q = "mimeType = 'application/vnd.google-apps.folder'")
#'
#' ## filter for Google Sheets
#' drive_search(type = "spreadsheet")
#' drive_search(q = "mimeType='application/vnd.google-apps.spreadsheet'")
#'
#' ## files whose names match a regex
#' drive_search(pattern = "jt")
#' }
#'
#' @export
drive_search <- function(pattern = NULL, type = NULL, ..., verbose = TRUE) {

  if (!is.null(pattern)) {
    if (!(is.character(pattern) && length(pattern) == 1)) {
      stop("Please update `pattern` to be a character string.", call. = FALSE)
    }
  }

  params <- list(...)

  if (is.null(params$fields)) {
    params$fields <- paste0("files/", .drive$default_fields, collapse = ",")
  }

  if (!is.null(type)) {
    ## if they are all NA, this will error, because drive_mime_type
    ## doesn't allow it, otherwise we proceed with the non-NA mime types
    mime_type <- drive_mime_type(type)
    mime_type <- purrr::discard(mime_type, is.na)
    params$q <- paste(
      c(params$q,
        paste0("mimeType = '", mime_type,"'", collapse = " or ")),
      collapse = " and "
    )
  }
  ## initialize q, if necessary
  ## by default, don't list items in trash
  if (is.null(params$q) || !grepl("trashed", params$q)) {
    ## TO DO: scrutinize what happens here when params$q is NULL
    params$q <- glue::collapse(c(params$q, "trashed = false"), sep = " and ")
  }

  request <- generate_request(endpoint = "drive.files.list", params = params)
  response <- make_request(request)
  proc_res <- process_response(response)

  res_tbl <- as_dribble(proc_res$files)

  if (is.null(pattern)) {
    return(res_tbl)
  }

  keep_names <- grep(pattern, res_tbl$name)
  if (length(keep_names) == 0L) {
    if (verbose) message(sprintf("No file names match the pattern: '%s'.", pattern))
    return(invisible())
  }
  as_dribble(res_tbl[keep_names, ]) ## TO DO change this once we get indexing working
}

.drive$default_fields <- c(
  "appProperties",
  "capabilities",
  "contentHints",
  "createdTime",
  "description",
  "explicitlyTrashed",
  "fileExtension",
  "folderColorRgb",
  "fullFileExtension",
  "headRevisionId",
  "iconLink",
  "id",
  "imageMediaMetadata",
  "kind",
  "lastModifyingUser",
  "md5Checksum",
  "mimeType",
  "modifiedByMeTime",
  "modifiedTime",
  "name",
  "originalFilename",
  "ownedByMe",
  "owners",
  "parents",
  "permissions",
  "properties",
  "quotaBytesUsed",
  "shared",
  "sharedWithMeTime",
  "sharingUser",
  "size",
  "spaces",
  "starred",
  "thumbnailLink",
  "trashed",
  "version",
  "videoMediaMetadata",
  "viewedByMe",
  "viewedByMeTime",
  "viewersCanCopyContent",
  "webContentLink",
  "webViewLink",
  "writersCanShare"
)
