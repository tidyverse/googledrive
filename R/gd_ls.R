#' Google Drive List
#'
#' @param token obtained from `gd_auth()`
#'
#' @return tibble of files
#' @export
#'
gd_ls <- function(){
  token <- .state$token
  req <- httr::GET(.state$gd_base_url_files_v3,token)
  httr::stop_for_status(req)
  reqlist <- httr::content(req, "parsed")
  if (length(reqlist) == 0) stop("Zero records match your url.\n")

  req_tbl <- tibble::tibble(
    name = purrr::map_chr(reqlist$files, "name"),
    type = sub('.*\\.', '',purrr::map_chr(reqlist$files, "mimeType")),
    id = purrr::map_chr(reqlist$files, "id")
  )
  req_tbl
}
