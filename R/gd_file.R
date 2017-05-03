#' Create a Google Drive file object
#'
#' @param id character, Google drive id for file of interest
#' @param ... name-value pairs to query the API
#'
#' @return object of class `drive_file` and `list`
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
      tibble::tibble(kind = character(), id = character(), type = character(),
                     emailAddress = character(), role = character(),displayName = character(),
                     photoLink = character(),deleted = character(), allowFileDiscovery = logical())
    } else if (length(proc_res$permissions) == 1) {
      tibble::as_data_frame(proc_res$permissions[[1]])
    } else {
      purrr::reduce(proc_res$permissions,dplyr::bind_rows)
    },
    #everything else
    kitchen_sink = proc_res
    # kitchen_sink = list(proc_res[!(names(proc_res) %in% c("name",
    #                                                       "id",
    #                                                       "mimeType",
    #                                                       "modifiedTime",
    #                                                       "createdTime",
    #                                                       "starred",
    #                                                       "permissions"))])
  )

  perm <- metadata$permissions

  if (sum(perm$id %in% c("anyone")) > 0){
    access <- "Anyone on the internet can find and access. No sign-in required."
  } else if (sum(perm$id %in% c("anyoneWithLink")) > 0){
    access <- "Anyone who has the link can access. No sign-in required."
  } else access <- "Shared with specific people."

  metadata$access <- access

  metadata <- structure(metadata, class = c("drive_file", "list"))
  metadata
}


#' @export
print.drive_file <- function(x, ...){
    cat(sprintf("File name: %s \nFile owner: %s \nFile type: %s \nLast modified: %s \nAccess: %s",
                x$name,
                x$owner,
                x$type,
                x$last_modified,
                x$access))
        invisible(x)
}

