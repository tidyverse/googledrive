#' Pull information about the Google Drive user
#'
#' @param fields the fields the user would like output - by default only `user`, which will display as detailed above.
#' @param verbose Logical, indicating whether to print informative messages (default \code{TRUE})
#'
#' @return a list of class \code{drive_user} with user's data
#' @export
#'
gd_user <- function(fields = "user", verbose = TRUE) {

  if (!token_available(verbose = verbose) || !is_legit_token(.state$token)) {
    if (verbose) {
      message("To retrieve user info, please call gs_auth() explicitly.")
    }
    return(invisible(NULL))
  }

  user_info <- drive_user(fields = fields)

  user_info

}

#' Google Drive User Information
#'
#' @param fields fields to query, default is `user`.
#'
#' @return list of class \code{drive_user} with user's information
#' @keywords internal

drive_user <- function(fields = "user") {
  #must have token
  if (!token_available(verbose = FALSE)) {
    return(NULL)
  }

  the_url <- file.path(.state$gd_base_url, "drive/v3/about")
  the_url <- httr::modify_url(the_url, query = list(fields = fields))

  req <- httr::GET(the_url, gd_token())
  httr::stop_for_status(req)
  rc <- content_as_json_UTF8(req)
  rc$date <- httr::parse_http_date(req$headers$date)
  structure(rc, class = c("drive_user", "list"))

}
