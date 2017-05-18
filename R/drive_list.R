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
    token = drive_token(),
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

get_leafmost_id <- function(path) {

  path_pieces <- unlist(strsplit(path, "/"))

  root_id <- root_folder() ## store so we don't make repeated API calls

  if (all(path_pieces == "~")) {
    return(root_id)
  }

  ## remove ~ if it was added to the beginning of the path (like ~/foo/bar/baz instead of foo/bar/baz)
  if (path_pieces[1] == "~") {
    path_pieces <- path_pieces[-1]
  }

  d <- length(path_pieces)
  path_pattern <- paste0("^", path_pieces, "$", collapse = "|")
  folders <- drive_list(
    pattern = path_pattern,
    fields = "files/parents,files/name,files/mimeType,files/id",
    q = "mimeType='application/vnd.google-apps.folder'",
    verbose = FALSE
  )

  if (!all(path_pieces %in% folders$name)){
    spf("We could not find the file path '%s' on your Google Drive", path)
  }
  ## guarantee: we have found at least one folder with correct name for
  ## each piece of path

  folders$depth <- match(folders$name, path_pieces)
  folders <- folders[order(folders$depth), ]

  ## the candidate return value(s)
  folder <- folders$id[folders$depth == d]

  ## TO DO:
  ## add a test case that explores path = foo/bar/baz when
  ## foo/yo/baz also exists, i.e. when folder will be of length >1 here

  ## can you get from folder to root by traversing a child-->parent chain
  ## within this set of folders?

  ## TO DO: add this as a test
  ## path = foo/bar/baz
  ## foo/bar/baz DOES exist
  ## but there are two folders named bar under foo, one of which hosts baz

  parent_is_present <- purrr::map_lgl(
    folders$parents,
    ~ any(.x %in% folders$id) | root_id %in% .x
  )
  parents <- folders$parents %>% purrr::flatten() %>% purrr::simplify()
  child_is_present <- purrr::map_lgl(
    folders$id,
    ~ .x %in% parents | .x %in% folder
  )

  ## pare down, now we know all but the final layer
  folders <- folders[parent_is_present & child_is_present, ]

  ## I have to rerun this because if there are x folders named foo and
  ## the one we are interested in is in the root, we will have multiple
  ## in "folder", but just want one.
  folder <- folders$id[folders$depth == d]

  # if there are multiple in depth d & it isn't the root
  if (length(folder) > 1) {
    leafmost_parent <- folders[folders$depth == d - 1, ]

    ## if there are 2 leafmost parents that got to this point, we have a
    ## double naming, throw an error
    if (length(leafmost_parent) > 1) {
      spf("The path '%s' is not uniquely defined.", path)
    }
    child_is_leafmost <- purrr::map_lgl(
      folders$parents,
      ~ .x == leafmost_parent$id
    )
    folder <- folders$id[child_is_leafmost]
  }
  if (!all(seq_len(d) %in% folders$depth)) {
    spf("Path not found: '%s'", path)
  }
  if (length(folder) > 1) {
    spf("Path is not unique: '%s'", path)
  }
  folder
}

## gets the root folder id
root_folder <- function() {
  request <- build_request(
    endpoint = "drive.files.get",
    token = drive_token(),
    params = list(fileId = "root"))
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
