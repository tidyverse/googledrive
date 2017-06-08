#' List Drive endpoints
#'
#' Returns a list of selected Drive API v3 endpoints, as stored inside the
#' googledrive package. The names of this list (or the `id` sub-elements) are
#' the nicknames that can be used to specify an endpoint in [build_request()].
#' For each endpoint, we store its nickname or `id`, the associated HTTP
#' verb, the `path`, and details about the parameters.
#'
#' @return A list containing the subset of the Drive API v3 endpoints that are
#'   used internally by googledrive.
#' @export
#'
#' @examples
#' str(drive_endpoints(), max.level = 2)
#' drive_endpoints()$`drive.files.delete`
drive_endpoints <- function() {
  .endpoints
}
