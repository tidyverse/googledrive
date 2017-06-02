#' Pull information about the Google Drive user.
#'
#' @param fields The fields the user would like output - by default only `user`,
#'   which will display as detailed above.
#' @param ... Name-value pairs to query the API.
#' @param verbose Logical, indicating whether to print informative messages
#'   (default `TRUE`).
#'
#' @return A list of class `drive_user` with user's data.
#' @export
#'
drive_user <- function(fields = "user", ..., verbose = TRUE) {

  if (!token_available(verbose = verbose) || !is_legit_token(.state$token)) {
    if (verbose) {
      message("To retrieve user info, please call gd_auth() explicitly.")
    }
    return(invisible(NULL))
  }

  user_info <- guser(fields = fields, ...)

  user_info

}

#' Google Drive User Information
#'
#' @param fields fields to query, default is `user`.
#' @param ... name-value pairs to query the API
#'
#' @return list of class \code{guser} with user's information
#' @keywords internal

guser <- function(fields = "user", ...) {

  if (!token_available(verbose = FALSE)) {
    return(NULL)
  }

  request <- build_request(
    endpoint = "drive.about.get",
    params = list(fields = fields,
                  ...))
  response <- make_request(request)
  proc_res <- process_response(response)
  proc_res$date <- httr::parse_http_date(request$headers$date)
  structure(proc_res, class = c("drive_user", "list"))

}
