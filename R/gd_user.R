#' Pull information about the Google Drive user
#'
#' @param fields the fields the user would like output - by default only `user`, which will display as detailed above.
#' @param ... name-value pairs to query the API
#' @param verbose Logical, indicating whether to print informative messages (default `TRUE`)
#'
#' @return a list of class `drive_user` with user's data
#' @export
#'
gd_user <- function(fields = "user",..., verbose = TRUE) {

  if (!token_available(verbose = verbose) || !is_legit_token(.state$token)) {
    if (verbose) {
      message("To retrieve user info, please call gd_auth() explicitly.")
    }
    return(invisible(NULL))
  }

  user_info <- drive_user(fields = fields,...)

  user_info

}

#' Google Drive User Information
#'
#' @param fields fields to query, default is `user`.
#' @param ... name-value pairs to query the API
#'
#' @return list of class \code{drive_user} with user's information
#' @keywords internal

drive_user <- function(fields = "user",...) {

  if (!token_available(verbose = FALSE)) {
    return(NULL)
  }

  url <- file.path(.state$gd_base_url, "drive/v3/about")

  req <- build_request(endpoint = url,
                       token = gd_token(),
                       params = list(fields = fields,
                                     ...))
  res <- make_request(req)
  proc_res <- process_request(res)
  proc_res$date <- httr::parse_http_date(req$headers$date)
  structure(proc_res, class = c("drive_user", "list"))

}
