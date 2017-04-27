#' Google Drive Get
#'
#' @param id document id obtained from `gd_ls`
#'
#' @return tibble
#' @export
#'
gd_get <- function(id, auth = TRUE){
  fields <- c("appProperties", "capabilities", "contentHints", "createdTime",
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
  fields <- paste(fields, collapse = ",")
  the_url <- file.path(.state$gd_base_url_files_v3, id)
  the_url <- httr::modify_url(the_url, query = list(fields = fields))
  req <- httr::GET(the_url, include_token_if(auth))
  httr::stop_for_status(req)
  metadata <- httr::content(req)

   metadata_tbl <- tibble::tibble(
     name = metadata$name,
     type = sub('.*\\.', '',metadata$mimeType),
     owner = purrr::map_chr(metadata$owners, 'displayName'), #what do we think about this? it would be a seperate line for all owners if < 1
     permission_who = ifelse(is.na(purrr::map_chr(metadata$permissions,'displayName', .null = NA)),
                              purrr::map_chr(metadata$permissions,'id', .null = NA),
                              purrr::map_chr(metadata$permissions,'displayName', .null = NA)),
     permission_role = purrr::map_chr(metadata$permissions, 'role'),
     permission_type = purrr::map_chr(metadata$permissions, 'type'),
     modified = lubridate::as_date(metadata$modifiedTime),
     object = list(metadata)
   )
 metadata_tbl
}
