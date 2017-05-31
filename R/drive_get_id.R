#' Get Google Drive id
#'
#' @param pattern character, regular expression to determin document title to
#'   output the Google Drive id If it is `NULL` (default), the most recently
#'   modified document id will be output.
#' @param n numeric, how many ids to output, default = 1
#' @param ... name-value pairs to query the API
#' @param verbose logical, indicating whether to print informative messages
#'   (default `TRUE`)
#'
#'
#' @return object of class`drive_id` & `list`, Google Drive id(s)
#' @export
drive_get_id <- function(pattern = NULL,
                         n = 1,
                         ...,
                         verbose = TRUE) {
  if ("orderBy" %in% names(list(...))) {
    ls <- drive_search(pattern = pattern, ...)
    if (!is.null(ls)) {
      id <- as.list(ls[1:n, 3])[[1]]
    }
  } else{
    ls <- drive_search(pattern = pattern,
                     orderBy = "modifiedTime desc",
                     ...)
    if (!is.null(ls)) {
      id <- as.list(ls[1:n, 3])[[1]]
    }
  }
  if (!is.null(ls)) {
    structure(id, class = c("drive_id", "list"))
  } else
    invisible(NULL)
}
