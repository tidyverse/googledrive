#' List files on Google Drive
#'
#' @param path character. Google Drive path to list. Defaults to "My Drive", but
#'   without regard to any folder hierarchy. If path is a folder, its contents
#'   are listed, not recursively. If path is a file, that single file is listed.
#'   A trailing slash indicates explicitly that the path is a folder, which can
#'   disambiguate if there is a file of the same name (yes this is possible on
#'   Drive!).
#' @param pattern character. If provided, only the files whose names match this
#'   regular expression are returned.
#' @param ... Parameters to pass along to the API query.
#' @param verbose logical. Indicates whether to print informative messages.
#'
#'   This will default to the most recent 100 files on your Google Drive. For
#'   example, to get 200 instead, specify the `pageSize`, i.e.
#'   `drive_ls(pageSize = 200)`.

#' Helpful links for forming queries:
#'   * <https://developers.google.com/drive/v3/web/search-parameters>
#'   * <https://developers.google.com/drive/v3/reference/files/list>

#' @return tibble with one row per file
#' @examples
#' \dontrun{
#' ## list "My Drive" w/o regard for folders
#' drive_list()
#'
#' ## list files that specifically live at the top-level of "My Drive"
#' drive_list("~/")
#'
#' ## just folders
#' drive_list(q = "mimeType = 'application/vnd.google-apps.folder'")
#'
#' ## just folders that have the folder with id 'abc' as direct parent
#' drive_list(q = "'abc' in parents and mimeType='application/vnd.google-apps.folder'")
#'
#' ## files that match a regex
#' drive_list(pattern = "jt")
#'
#' ## list the contents of the 'jt01' folder
#' drive_list("jt01/")
#'
#' ## list user's Google Sheets
#' drive_list(q = "mimeType='application/vnd.google-apps.spreadsheet'")
#' }
#'
#' @export
drive_list <- function(path = NULL, pattern = NULL, ..., verbose = TRUE) {

  if (!is.null(pattern)) {
    if (!(is.character(pattern) && length(pattern) == 1)) {
      stop("Please update `pattern` to be a character string.", call. = FALSE)
    }
  }

  params <- list(...)

  if (is.null(params$fields)) {
    params$fields <- paste0("files/", .drive$default_fields, collapse = ",")
  }

  ## initialize q, if necessary
  ## by default, don't list items in trash
  if (is.null(params$q) || !grepl("trashed", params$q)) {
    ## TO DO: scrutinize what happens here when params$q is NULL
    params$q <- glue::collapse(c(params$q, "trashed = false"), sep = " and ")
  }

  if (!is.null(path) && grepl("^~$|^/$|^~/$", path)) {
    q_root <- glue::glue("{sq(root_id())} in parents")
    params$q <- glue::collapse(c(params$q, q_root), sep = " and ")
    path <- NULL
  }
  path <- normalize_path(path)

  ## if path is specified, we call the API twice
  ## once to learn id of the folder to list
  ## then again to list the contents
  if (!is.null(path)) {
    leaf <- get_leaf(path)
    if (leaf$mimeType == "application/vnd.google-apps.folder") {
      ## path identifies a folder
      ## we will list it
      parent_id <- leaf$id
    } else {
      ## path identifies a file
      ## we will list its parent, but restrict to the file's name
      ## simplest way to get a single file back in "drive_list()" style
      parent_id <- leaf$parent_id
      q_name <- glue::glue("name = {sq(name)}", name = basename(path))
      params$q <- glue::collapse(c(params$q, q_name), sep = " and ")
    }
    q_parent <- glue::glue("{sq(parent_id)} in parents")
    params$q <- glue::collapse(c(params$q, q_parent), sep = " and ")
  }

  request <- build_request(params = params)
  response <- make_request(request)
  proc_res <- process_response(response)

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
