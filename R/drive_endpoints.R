#' List Drive endpoints
#'
#' @description
#' The googledrive package stores a named list of Drive API v3 endpoints (or
#' "methods", using Google's vocabulary) internally and these functions expose
#' this data.
#'   * `drive_endpoint()` returns one endpoint, i.e. it uses `[[`.
#'   * `drive_endpoints()` returns a list of endpoints, i.e. it uses `[`.
#'
#' The names of this list (or the `id` sub-elements) are the nicknames that can
#' be used to specify an endpoint in [request_generate()]. For each endpoint, we
#' store its nickname or `id`, the associated HTTP verb, the `path`, and details
#' about the parameters. This list is derived programmatically from the Drive
#' API v3 Discovery Document
#' (`https://www.googleapis.com/discovery/v1/apis/drive/v3/rest`) using the
#' approach described in the [Discovery Documents
#' section](https://gargle.r-lib.org/articles/request-helper-functions.html#discovery-documents)
#' of the gargle vignette [Request helper
#' functions](https://gargle.r-lib.org/articles/request-helper-functions.html).
#'
#' @param i The name(s) or integer index(ices) of the endpoints to return. `i`
#'   is optional for `drive_endpoints()` and, if not given, the entire list is
#'   returned.
#'
#' @return One or more of the Drive API v3 endpoints that are used internally by
#'   googledrive.
#' @export
#'
#' @examples
#' str(head(drive_endpoints(), 3), max.level = 2)
#' drive_endpoint("drive.files.delete")
#' drive_endpoint(4)
drive_endpoints <- function(i = NULL) {
  if (is.null(i) || is_expose(i)) {
    i <- seq_along(.endpoints)
  }
  stopifnot(is.character(i) || (is.numeric(i)))
  .endpoints[i]
}

#' @rdname drive_endpoints
#' @export
drive_endpoint <- function(i) {
  stopifnot(is_string(i) || (is.numeric(i) && length(i) == 1))
  .endpoints[[i]]
}
