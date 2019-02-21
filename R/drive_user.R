#' Get info on current user
#'
#' Reveals information about the user associated with the current token. This is
#' a thin wrapper around [drive_about()] that just extracts the most useful
#' information (the information on current user) and prints it nicely.
#'
#' @seealso Wraps the `about.get` endpoint:
#'   * <https://developers.google.com/drive/v3/reference/about/get>
#'
#' @template verbose
#'
#' @return A list of class `drive_user`.
#' @export
#' @examples
#' \dontrun{
#' drive_user()
#'
#' ## more info is returned than is printed
#' user <- drive_user()
#' user[["permissionId"]]
#' }
drive_user <- function(verbose = TRUE) {
  if (isFALSE(.auth$auth_active)) {
    if (verbose) {
      message("Not logged in as any specific Google user.")
    }
    return(invisible())
  }
  about <- drive_about()
  structure(about[["user"]], class = c("drive_user", "list"))
}

#' @export
print.drive_user <- function(x, ...) {
  cat(
    c(
      "Logged in as:",
      glue("  *  displayName: {x[['displayName']]}"),
      glue("  * emailAddress: {x[['emailAddress']]}")
    ),
    sep = "\n"
  )
  invisible(x)
}
