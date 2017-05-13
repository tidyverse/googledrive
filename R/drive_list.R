#' List files on Google Drive
#'
#' @param path character vector, path where the Google drive files are
#'   that you would like to list. Defaults to the "My Drive" directory.
#' @param pattern character vector, regular expression(s) of title(s) of
#'   documents to output in a tibble. If it is `NULL` (default), information
#'   about all documents in drive will be output in a tibble.
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
    folder_nms <- unlist(strsplit(path, "/"))
    folder_pattern <- paste0("^", folder_nms, "$", collapse = "|")
    folder_order <- tibble::tibble(
      name = folder_nms,
      dir = seq_along(folder_nms)
      )
    folder_tbl <- drive_list(pattern = folder_pattern,
                             fields = paste0("files/parents,files/name,files/mimeType,files/id"),
                             q = "mimeType='application/vnd.google-apps.folder'")

    if (!all(folder_nms %in% folder_tbl$name)){
      spf("We could not find the file path '%s' on your Google Drive", path)
    }

    # merge in to get the correct directory order & sort, oh how I miss the %>% :(
    folder_tbl <- tibble::as_data_frame(merge(folder_tbl, folder_order, by = "name"))
    folder_tbl_sort <- folder_tbl[order(folder_tbl$dir), ]

    parent_id <- root_folder()
    keep_folders <- NULL
    for (i in 1:nrow(folder_tbl_sort)){
      subfolder <- folder_tbl_sort[i, ]
      keep <- subfolder$folder_id == parent_id
      if (keep){
        parent_id <- subfolder$id
      }
      keep_folders[i] <- keep
    }

    folder_tbl_keep <- folder_tbl_sort[keep_folders, ]
    leafmost <- nrow(folder_tbl_keep)
    if (leafmost != length(folder_nms)){
      spf("Uh oh, something went wrong. We could not find the path '%s' on your Google Drive", path)
    }

    folder <- folder_tbl_keep[leafmost, "id"]
  }
  x <- list(...)

  #add default fields if null
  if (is.null(x$fields)){
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
    x$fields <- paste0("files/", default_fields, collapse = ",")
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




  request <- build_request(endpoint = .state$drive_base_url_files_v3,
                           token = drive_token(),
                           params = x)
  response <- make_request(request)
  proc_res <- process_request(response)
  req_tbl <- tibble::tibble(
    name = purrr::map_chr(proc_res$files, "name"),
    type = sub(".*\\.", "", purrr::map_chr(proc_res$files, "mimeType")),
    folder_id = purrr::map_chr(purrr::map(proc_res$files, "parents", .null = NA), 1),
    id = purrr::map_chr(proc_res$files, "id"),
    gfile = proc_res$files)

  if (is.null(pattern)){
    return(req_tbl)
  } else{
    if (!inherits(pattern, "character")){
      stop("Please update `pattern` to be a character string or vector of character strings.")
    }
  }

  if (length(pattern) > 1) {
    pattern <- paste(pattern, collapse = "|")
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
