#' Get Google Drive id
#'
#' @param search character, regular expression to determin document title to output the Google Drive id
#' If it is `NULL` (default), the most recently modified document id will be output.
#' @param ... name-value pairs to query the API
#' @param fixed logical, from `[grep()]`. If `TRUE`, `search` is exactly matched to a
#' document's name on Google Drive.
#' @param verbose logical, indicating whether to print informative messages (default `TRUE`)
#'
#'
#' @return character, Google Drive id
#' @export
gd_get_id <- function(search, ..., fixed = FALSE, verbose = TRUE){

  #if (missing(orderBy)) orderBy = "modifiedTime desc"

  id <- as.character(gd_ls(search = search, fixed = fixed, orderBy="modifiedTime desc")[1,3])
  structure(id, class=c("drive_id","character"))
}
