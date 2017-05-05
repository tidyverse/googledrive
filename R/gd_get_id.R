#' Get Google Drive id
#'
#' @param search character, regular expression to determin document title to output the Google Drive id
#' If it is `NULL` (default), the most recently modified document id will be output.
#' @param n numeric, how many ids to output, default = 1
#' @param ... name-value pairs to query the API
#' @param fixed logical, from `[grep()]`. If `TRUE`, `search` is exactly matched to a
#' document's name on Google Drive.
#' @param verbose logical, indicating whether to print informative messages (default `TRUE`)
#'
#'
#' @return object of class`drive_id` & `list`, Google Drive id(s)
#' @export
gd_get_id <- function(search, n = 1, ..., fixed = FALSE, verbose = TRUE){

  if ("orderBy" %in% names(list(...))){
    id <- as.list(gd_ls(search = search, fixed = fixed, ...)[1:n,3])[[1]]
  } else{
    id <- as.list(gd_ls(search = search, fixed = fixed, orderBy="modifiedTime desc", ...)[1:n,3])[[1]]
  }

  structure(id, class=c("drive_id","list"))
}
