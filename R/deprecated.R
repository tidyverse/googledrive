#' Deprecated googledrive functions
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' @section `drive_auth_config()`:
#'
#' This function is defunct.
#' * Use [drive_auth_configure()] to configure your own OAuth client or API key.
#' * Use [drive_deauth()] to go into a de-authorized state.
#' * Use [drive_oauth_client()] to retrieve a user-configured client, if it
#'   exists.
#' * Use [drive_api_key()] to retrieve a user-configured API key, if it exists.
#'
#' @section `drive_oauth_app()`:
#'
#' In light of the new [gargle::gargle_oauth_client()] constructor and class of
#' the same name, `drive_oauth_app()` is being replaced by
#' [drive_oauth_client()].
#'
#' @section `drive_example()`:
#'
#' This function is defunct. Access example files with [drive_examples_local()],
#' [drive_example_local()], [drive_examples_remote()], and
#' [drive_example_remote()].
#'
#' @keywords internal
#' @name googledrive-deprecated
NULL

#' @rdname googledrive-deprecated
#' @inheritParams drive_auth_configure
#' @export
drive_auth_config <- function(active, app, path, api_key) {
  lifecycle::deprecate_stop(
    "1.0.0",
    "drive_auth_config()",
    details = c(
      "Use `drive_auth_configure()` to configure your own OAuth client or API key.",
      "Use `drive_deauth()` to go into a de-authorized state.",
      "Use `drive_oauth_client()` to retrieve a user-configured client, if it exists.",
      "Use `drive_api_key()` to retrieve a user-configured API key, if it exists."
    )
  )
}

#' @rdname googledrive-deprecated
#' @export
drive_oauth_app <- function() {
  lifecycle::deprecate_warn(
    "2.1.0",
    "drive_oauth_app()",
    "drive_oauth_client()"
  )
  drive_oauth_client()
}

#' @rdname googledrive-deprecated
#' @export
drive_example <- function(path = NULL) {
  lifecycle::deprecate_stop(
    "2.0.0",
    what = "drive_example()",
    with = I("`drive_examples_local()` or `drive_example_local()`")
  )
}
