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
    if (!(inherits(pattern, "character") && length(pattern) == 1)) {
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

  request <- build_request(
    endpoint = .drive$base_url_files_v3,
    token = drive_token(),
    params = x
  )
  response <- make_request(request)
  proc_res <- process_request(response)

  req_tbl <- tibble::tibble(
    name = purrr::map_chr(proc_res$files, "name"),
    type = sub(".*\\.", "", purrr::map_chr(proc_res$files, "mimeType")),
    ## FIXME: all parents should be taken, not just the first
    ## parents should be a list-column
    parents = purrr::map_chr(proc_res$files, list("parents", 1), .null = NA),
    id = purrr::map_chr(proc_res$files, "id"),
    gfile = proc_res$files
  )

  if (is.null(pattern)) {
    return(req_tbl)
  }

  keep_names <- grep(pattern, req_tbl$name)
  if (length(keep_names) == 0L) {
    if (verbose) message(sprintf("No file names match the pattern: '%s'.", pattern))
    return(invisible())
  }
  req_tbl[keep_names, ]
}

get_leafmost_id <- function(path) {

  path_pieces <- unlist(strsplit(path, "/"))
  d <- length(path_pieces)
  path_pattern <- paste0("^", path_pieces, "$", collapse = "|")
  folders <- drive_list(
    pattern = path_pattern,
    fields = "files/parents,files/name,files/mimeType,files/id",
    q = "mimeType='application/vnd.google-apps.folder'"
  )
  ## FIXME
  ## seems like the "parents" variable should be a list-column?
  ## can't parents technically have length greater than one?

  if (!all(path_pieces %in% folders$name)){
    spf("We could not find the file path '%s' on your Google Drive", path)
  }
  ## guarantee: we have found at least one folder with correct name for
  ## each piece of path

  folders$depth <- match(folders$name, path_pieces)
  folders <- folders[order(folders$depth), ]
  folder <- folders$id[folders$depth == d]
  if (length(folder) != 1) {
    spf("'%s' does not uniquely define a single path", path)
  }
  ## guarantee: there is exactly one folder at depth d

  ## can you get from folder to root by traversing a child-->parent chain
  ## within this set of folders?

  ## TO DO: add this as a test
  ## path = foo/bar/baz
  ## foo/bar/baz DOES exist
  ## but there are two folders named bar under foo, one of which hosts baz

  # FIXME: account for parents being a list-col of parents,
  ## i.e. .x is a character of parent ids
  root_id <- root_folder() ## store so we don't make repeated API calls
  parent_is_present <- purrr::map_lgl(
    folders$parents,
    ~ .x %in% folders$id | .x == root_id
  )
  child_is_present <- purrr::map_lgl(
    folders$id,
    ~ .x %in% folders$parents | .x == folder
  )
  folders <- folders[parent_is_present & child_is_present, ]
  if (!all(seq_len(d) %in% folders$depth)) {
    spf("Path not found: '%s'", path)
  }
  folder
}

## gets the root folder id
root_folder <- function() {
  url <- file.path(.drive$base_url_files_v3, "root")
  request <- build_request(endpoint = url,
                           token = drive_token())
  response <- make_request(request)
  proc_res <- process_request(response)
  proc_res$id

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
