#' List files on Google Drive
#'
#' @param path character vector, path name(s) where the Google drive files are that you
#'   would like to list. Defaults to the "My Drive" directory.
#' @param pattern character vector, regular expression(s) of title(s) of documents to
#'   output in a tibble. If it is `NULL` (default), information about all
#'   documents in drive will be output in a tibble.
#' @param ... name-value pairs to query the API
#' @param fixed logical, from [grep()]. If `TRUE`, `pattern` is exactly matched
#'   to a document's name on Google Drive.
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#' This will default to the most recent 100 files on your Google Drive. If you
#' would like more than 100, include the `pageSize` parameter. For example, if I
#' wanted 200, I would run `drive_ls(pageSize = 200)`.
#'
#' Helpful links for forming queries:
#'   * <https://developers.google.com/drive/v3/web/search-parameters>
#'   * <https://developers.google.com/drive/v3/reference/files/list>
#
#' @return tibble containing the name, type, and id of files on your google
#'   drive (default 100 files)
#' @examples
#' \dontrun{
#' ## list user's Google Sheets
#' drive_ls(q = "mimeType='application/vnd.google-apps.spreadsheet'")
#' }
#'
#' @export
drive_ls <- function(path = NULL, pattern = NULL, ..., fixed = FALSE, verbose = TRUE){

  folder <- NULL

  if (!is.null(path)){
    folder <- climb_folders(path = path)
  }

  request <- build_drive_ls(..., folder = folder)
  response <- make_request(request)
  process_drive_ls(response = response, pattern = pattern, fixed = fixed, verbose = verbose)

}

climb_folders <- function(path = NULL, my_folders = drive_folders()){

  folders <- unlist(strsplit(path, "/"))
  my_folder_ids <- purrr::map(folders,folder_ids, folder_tbl = my_folders)

  if (!any(my_folder_ids[[1]]$root)){
    spf("We could not find a folder named '%s' in your 'My Drive' (root) directory.", folders[1])
  }

  #it is v silly that Google Drive allows this but...
  if (!sum(my_folder_ids[[1]]$root)==1){
    spf("It seems you have more than one folder named '%s' in your 'My Drive' (root) directory.", folders[1])
  }

  len <- length(my_folder_ids)
  f1 <- my_folder_ids[1:(len-1)]
  f2 <- my_folder_ids[2:len]
  folder_guess <- purrr::map2(f1, f2, folder_check)
  while (nrow(my_folder_ids[[len-1]]) != 1){
    len <- length(my_folder_ids)
    f1 <- my_folder_ids[1:(len-1)]
    f2 <- my_folder_ids[2:len]
    my_folder_ids <- purrr::map2(f1, f2, folder_check)
  }
  folder <- my_folder_ids[[len-1]]$id
}
build_drive_ls <- function(..., folder = NULL, token = drive_token()){

  ## add fields
  default_fields <-
    c(
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
  fields <- paste0("files/",default_fields, collapse = ",")

  x <- list(...)

  if (!is.null(folder)){
    parents <- paste0("'",folder,"'"," in parents")
    if ("q" %in% names(x)){
      x$q <- paste(x$q, "and", parents)
    } else {
      x$q <- parents
    }
  }
  x$fields <- fields
  build_request(endpoint = .state$drive_base_url_files_v3,
                token = token,
                params = x)

}

process_drive_ls <- function(response = NULL,
                             pattern = NULL,
                             fixed = FALSE,
                             verbose = TRUE) {
  proc_res <- process_request(response)

  location <- tibble::tibble(
    id = purrr::map_chr(proc_res$files, "id"),
    parent = purrr::map(proc_res$files,"parents")
  )
  req_tbl <- tibble::tibble(
    name = purrr::map_chr(proc_res$files, "name"),
    type = sub('.*\\.', '',purrr::map_chr(proc_res$files, "mimeType")),
    id = purrr::map_chr(proc_res$files, "id"),
    gfile = proc_res$files)

  req_tbl$gfile <- structure(req_tbl$gfile, class = c("gfile", "list"))

  if (is.null(pattern)){
    return(req_tbl)
  } else{
    if(!inherits(pattern, "character")){
      stop("Please update `pattern` to be a character string or vector of character strings.")
    }
  }

  if (length(pattern) > 1) {
    pattern <- paste(pattern, collapse = "|")
  }

  keep_names <- grep(pattern, req_tbl$name, fixed = fixed)

  if(length(keep_names) == 0L){
    if(verbose){
      message(sprintf("We couldn't find any documents matching '%s'. \nTry updating your `pattern` critria.", gsub("\\|", "' or '", pattern)))
    }
    invisible(NULL)
  } else
    req_tbl[keep_names,]
}
