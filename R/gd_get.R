#' Google Drive Get
#'
#' @param id document id obtained from `gd_ls`
#' @param ... name-value pairs to query the API
#' @param fields user can input an vector of fields - defaults to all fields
#' @param auth default TRUE
#'
#' @return tibble
#' @export
#'
gd_get <- function(id, ..., fields = default_fields, auth = TRUE){

  fields <- paste(fields, collapse = ",")
  url <- file.path(.state$gd_base_url_files_v3, id)

  req <- build_request(endpoint = url,
                       token = gd_token(),
                       params = list(...,
                                     "fields" = fields))
  res <- make_request(req)
  metadata <- process_request(res)

   metadata_tbl <- tibble::tibble(
     name = metadata$name,
     type = sub('.*\\.', '',metadata$mimeType),
     owner = purrr::map_chr(metadata$owners, 'displayName'), #what do we think about this? it would be a seperate line for all owners if < 1
     #can only see this if you are the owner..shoot
     # permission_who = ifelse(is.na(purrr::map_chr(metadata$permissions,'displayName', .null = NA)),
     #                          purrr::map_chr(metadata$permissions,'id', .null = NA),
     #                          purrr::map_chr(metadata$permissions,'displayName', .null = NA)),
     # permission_role = purrr::map_chr(metadata$permissions, 'role'),
     # permission_type = purrr::map_chr(metadata$permissions, 'type'),
     modified = as.Date(metadata$modifiedTime),
     object = list(metadata)
   )
 metadata_tbl
}
