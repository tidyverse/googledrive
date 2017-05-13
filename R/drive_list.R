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

  folder <- NULL
  if (!is.null(path)) {
    folder <- get_leafmost_id(path = path)
  }
  x <- list(...)

  #add default fields if null
  if (is.null(x$fields)) {
    x$fields <- paste0("files/", .drive$default_fields, collapse = ",")
  }

  #add folder if not null
  if (!is.null(folder)){
    q <- paste0("'", folder, "'", " in parents")
    if (!is.null(x$q)){
      x$q <- paste(x$q, "and", q)
    } else {
      x$q <- q
    }
  }




  request <- build_request(endpoint = .drive$base_url_files_v3,
                           token = drive_token(),
                           params = x)
  response <- make_request(request)
  proc_res <- process_request(response)
  req_tbl <- tibble::tibble(
    name = purrr::map_chr(proc_res$files, "name"),
    type = sub(".*\\.", "", purrr::map_chr(proc_res$files, "mimeType")),
    folder_id = purrr::map_chr(
      purrr::map(
        proc_res$files,
        "parents",
        .null = NA
      ),
      1),
    id = purrr::map_chr(proc_res$files, "id"),
    gfile = proc_res$files)

  if (is.null(pattern)){
    return(req_tbl)
  } else{
    if (!(inherits(pattern, "character") & length(pattern) == 1)){
      stop("Please update `pattern` to be a character string.")
    }
  }

  keep_names <- grep(pattern, req_tbl$name)

  if (length(keep_names) == 0L){
    if (verbose){
      message(sprintf("We couldn't find any documents matching '%s'. \nTry updating your `pattern` critria.", gsub("\\|", "' or '", pattern)))
    }
    invisible(NULL)
  } else
    req_tbl[keep_names, ]
}

get_leafmost_id <- function(path) {

  path_pieces <- tibble::tibble(
    name =  unlist(strsplit(path, "/")),
    depth = seq_along(name)
  )
  d <- max(path_pieces$depth)
  path_pattern <- paste0("^", path_pieces$name, "$", collapse = "|")
  folders <- drive_list(
    pattern = path_pattern,
    fields = "files/parents,files/name,files/mimeType,files/id",
    q = "mimeType='application/vnd.google-apps.folder'"
  )
  ## FIXME
  ## seems like the tibble returned above should have a "parents" variable?
  ## and that it should be a list-column, not character
  ## can't parents technically have length greater than one?
  ## temporarily just fixing the name
  folders$parents <- folders$folder_id
  folders$folder_id <- NULL

  if (!all(path_pieces$name %in% folders$name)){
    spf("We could not find the file path '%s' on your Google Drive", path)
  }
  ## guarantee: we have found at least one folder with correct name for
  ## each piece of path

  folders <- tibble::as_tibble(merge(folders, path_pieces, by = "name"))
  folder <- folders$id[folders$depth == d]
  if (length(folder) != 1) {
    spf("'%s' does not uniquely define a single path", path)
  }
  ## guarantee: there is exactly one folder at depth d

  ## the only task left is to make sure you can get from folder to root
  ## by traversing a child-->parent chain of relationships
  ## once that's established, you know folder is good and you return it

  ## FIXME: this is too simple, I think this will have to be recursive
  ## example that breaks it: path = foo/bar/baz
  ## foo/bar/baz DOES exist
  ## but there is a second folder named bar under foo
  folders <- folders[order(folders$depth), ]
  parent_id <- root_folder()
  keep_folders <- NULL
  for (i in seq_len(nrow(folders))) {
    subfolder <- folders[i, ]
    keep <- subfolder$parents == parent_id
    if (keep) {
      parent_id <- subfolder$id
    }
    keep_folders[i] <- keep
  }

  if (!keep_folders[length(keep_folders)]) {
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
