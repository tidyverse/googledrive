#' Google Drive List
#'
#' @param token obtained from `gd_auth()`
#'
#' @return tibble of files
#' @export
#'
gd_ls <- function(){
  token <- .state$token
  url <- "https://www.googleapis.com/drive/v3/files"
  req <- httr::GET(url,token)
  if (req$status_code >= 400) {
    stop(
      sprintf(
        "Google API returned an error: HTTP status code %s, %s",
        req$status_code,
        req$headers$statusmessage
      )
    )
  }
  httr::stop_for_status(req)
  reqlist <- httr::content(req, "parsed")
  if (length(reqlist) == 0) stop("Zero records match your url.\n")

  req_tbl <- tibble::tibble(
    id             = purrr::map_chr(reqlist$files, "id") ,
    title          = purrr::map_chr(reqlist$files, "name")
  )
  req_tbl
}
