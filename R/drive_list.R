#' List files on Google Drive
#'
#' @param path character, path where the Google drive files are
#'   that you would like to list. Defaults to the "My Drive" directory.
#' @param pattern character, regular expression of titles of
#'   documents to output in a tibble.
#' @param ... name-value pairs to query the API
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#'   This will default to the most recent 100 files on your Google Drive. If you
#'   would like more than 100, include the `pageSize` parameter. For example, if
#'   I wanted 200, I would run `drive_ls(pageSize = 200)`.

#' Helpful links for forming queries:
#'   * <https://developers.google.com/drive/v3/web/search-parameters>
#'   * <https://developers.google.com/drive/v3/reference/files/list>

#' @return tibble containing the name, type, and id of files on your google
#'   drive (default 100 files)
#' @examples
#' \dontrun{
#' ## list user's Google Sheets
#' drive_list(q = "mimeType='application/vnd.google-apps.spreadsheet'")
#' }
#'
#' @export
drive_list <- function(path = NULL, pattern = NULL, ..., verbose = TRUE){

  if (!is.null(pattern)) {
    if (!(is.character(pattern) && length(pattern) == 1)) {
      stop("Please update `pattern` to be a character string.", call. = FALSE)
    }
  }

  x <- list(...)

  if (is.null(x$fields)) {
    x$fields <- paste0("files/", .drive$default_fields, collapse = ",")
  }

  if (!is.null(path)) {
    folder <- get_leafmost_id(path = path)
    q <- paste0("'", folder, "'", " in parents")
    if (is.null(x$q)) {
      x$q <- q
    } else {
      x$q <- paste(x$q, "and", q)
    }
  }

  ## make sure it isn't in the trash

  if (is.null(x$q)) {
    x$q <- "trashed = false"
  } else {
    ## but if they want it to be it could be
    trash <- grepl("trashed", x$q)
    if (!trash) {
      x$q <- paste(x$q, "and trashed = false")
    }
  }

  if (is.null(path)) {
    path = "~/"
  }

  request <- build_request(
    params = x
  )
  response <- make_request(request)
  proc_res <- process_request(response)

  req_tbl <- tibble::tibble(
    name = purrr::map_chr(proc_res$files, "name"),
    type = sub(".*\\.", "", purrr::map_chr(proc_res$files, "mimeType")),
    parents = purrr::map(proc_res$files, "parents"),
    id = purrr::map_chr(proc_res$files, "id"),
    gfile = proc_res$files
  )

  if (is.null(pattern)) {
    if (nrow(req_tbl) == 0) {
      if (verbose) message(sprintf("There are no files in Google Drive path: '%s'", path))
    }
    return(req_tbl)
  }

  keep_names <- grep(pattern, req_tbl$name)
  if (length(keep_names) == 0L) {
    if (verbose) message(sprintf("No file names match the pattern: '%s'.", pattern))
    return(invisible())
  }
  req_tbl[keep_names, ]
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
