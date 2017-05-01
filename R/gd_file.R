#' Create a Google Drive file object
#'
#' @param id character, Google drive id for file of interest
#' @param ... name-value pairs to query the API
#'
#' @return object of class \code{drive_file} and \code{list}
#' @export
#'
gd_file <- function(id, ...){
  default_fields <- c("appProperties", "capabilities", "contentHints", "createdTime",
                      "description", "explicitlyTrashed", "fileExtension",
                      "folderColorRgb", "fullFileExtension", "headRevisionId",
                      "iconLink", "id", "imageMediaMetadata", "kind",
                      "lastModifyingUser", "md5Checksum", "mimeType",
                      "modifiedByMeTime", "modifiedTime", "name", "originalFilename",
                      "ownedByMe", "owners", "parents", "permissions", "properties",
                      "quotaBytesUsed", "shared", "sharedWithMeTime", "sharingUser",
                      "size", "spaces", "starred", "thumbnailLink", "trashed",
                      "version", "videoMediaMetadata", "viewedByMe", "viewedByMeTime",
                      "viewersCanCopyContent", "webContentLink", "webViewLink",
                      "writersCanShare")
  fields <- paste(default_fields, collapse = ",")
  url <- file.path(.state$gd_base_url_files_v3, id)

  req <- build_request(endpoint = url,
                       token = gd_token(),
                       params = list(...,
                                     "fields" = fields))
  res <- make_request(req)
  proc_res <- process_request(res)

  metadata <- list(
    name = proc_res$name,
    id = proc_res$id,
    type = sub('.*\\.', '',proc_res$mimeType),
    owner = purrr::map_chr(proc_res$owners, 'displayName'),
    last_modified = as.Date(proc_res$modifiedTime),
    created = as.Date(proc_res$createdTime),
    starred = proc_res$starred,
    #make a tibble of permissions - this seems a bit silly how I've done it so far.
    permissions = if (is.null(proc_res$permissions)) {
      tibble::tibble()
    } else if (length(proc_res$permissions) == 1) {
      tibble::as_data_frame(proc_res$permissions[[1]])
    } else {
      purrr::reduce(proc_res$permissions,dplyr::bind_rows)
    },
    #everything else
    kitchen_sink = list(proc_res)
    # kitchen_sink = list(proc_res[!(names(proc_res) %in% c("name",
    #                                                       "id",
    #                                                       "mimeType",
    #                                                       "modifiedTime",
    #                                                       "createdTime",
    #                                                       "starred",
    #                                                       "permissions"))])
  )

  metadata <- structure(metadata, class = c("drive_file", "list"))
  metadata
}


#' @export
print.drive_file <- function(x, ...){
    cat(sprintf("File name: %s \nFile owner: %s \nFile type: %s \nLast modified: %s \n",
                x$name,
                x$owner,
                x$type,
                x$last_modified))
        invisible(x)
}

