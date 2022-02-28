#' Deprecated googledrive functions
#'
#' @keywords internal
#' @name googledrive-deprecated
NULL

#' @rdname googledrive-deprecated
#' @inheritParams drive_auth_configure
#' @export
drive_auth_config <- function(active, app, path, api_key) {
  lifecycle::deprecate_warn(
    "1.0.0",
    "drive_auth_config()",
    details = c(
     "Use `drive_auth_configure()` to configure your own OAuth app or API key.",
     "Use `drive_deauth()` to go into a de-authorized state.",
     "Use `drive_oauth_app()` to retrieve a user-configured app, if it exists.",
     "Use `drive_api_key()` to retrieve a user-configured API key, if it exists."
    )
  )
  drive_auth_configure(app = app, path = path, api_key = api_key)
}
