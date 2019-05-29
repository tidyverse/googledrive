## This file is the interface between googledrive and the
## auth functionality in gargle.

.auth <- gargle::init_AuthState(
  package     = "googledrive",
  app         = gargle::tidyverse_app(),
  api_key     = gargle::tidyverse_api_key(),
  auth_active = TRUE
)

## The roxygen comments for these functions are mostly generated from data
## in this list and template text maintained in gargle.
gargle_lookup_table <- list(
  PACKAGE     = "googledrive",
  YOUR_STUFF  = "your Drive files",
  PRODUCT     = "Google Drive",
  API         = "Drive API",
  PREFIX      = "drive",
  AUTH_CONFIG_SOURCE = "tidyverse"
)

#' Authorize googledrive
#'
#' @eval gargle:::PREFIX_auth_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_details(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_params()
#'
#' @family auth functions
#' @export
#'
#' @examples
#' \dontrun{
#' ## load/refresh existing credentials, if available
#' ## otherwise, go to browser for authentication and authorization
#' drive_auth()
#'
#' ## see user associated with current token
#' drive_user()
#'
#' ## force use of a token associated with a specific email
#' drive_auth(email = "jenny@example.com")
#' drive_user()
#'
#' ## force a menu where you can choose from existing tokens or
#' ## choose to get a new one
#' drive_auth(email = NA)
#'
#' ## use a 'read only' scope, so it's impossible to edit or delete files
#' drive_auth(
#'   scopes = "https://www.googleapis.com/auth/drive.readonly"
#' )
#'
#' ## use a service account token
#' drive_auth(path = "foofy-83ee9e7c9c48.json")
#' }
drive_auth <- function(email = NULL,
                       path = NULL,
                       scopes = "https://www.googleapis.com/auth/drive",
                       cache = gargle::gargle_oauth_cache(),
                       use_oob = gargle::gargle_oob_default(),
                       token = NULL) {
  cred <- gargle::token_fetch(
    scopes = scopes,
    app = drive_oauth_app(),
    email = email,
    path = path,
    package = "googledrive",
    cache = cache,
    use_oob = use_oob,
    token = token
  )
  if (!inherits(cred, "Token2.0")) {
    stop(
      "Can't get Google credentials.\n",
      "Are you running googledrive in a non-interactive session? Consider:\n",
      "  * `drive_deauth()` to prevent the attempt to get credentials.\n",
      "  * Call `drive_auth()` directly with all necessary specifics.\n",
      call. = FALSE
    )
  }
  .auth$set_cred(cred)
  .auth$set_auth_active(TRUE)

  invisible()
}

#' Suspend authorization
#'
#' @eval gargle:::PREFIX_deauth_description(gargle_lookup_table)
#'
#' @family auth functions
#' @export
#' @examples
#' \dontrun{
#' drive_deauth()
#' drive_user()
#' public_file <-
#'   drive_get(as_id("1Hj-k7NpPSyeOR3R7j4KuWnru6kZaqqOAE8_db5gowIM"))
#' drive_download(public_file)
#' }
drive_deauth <- function() {
  .auth$set_auth_active(FALSE)
  .auth$set_cred(NULL)
  invisible()
}

#' Produce configured token
#'
#' @eval gargle:::PREFIX_token_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_token_return()
#'
#' @family low-level API functions
#' @export
#' @examples
#' \dontrun{
#' req <- request_generate(
#'   "drive.files.get",
#'   list(fileId = "abc"),
#'   token = drive_token()
#' )
#' req
#' }
drive_token <- function() {
  if (isFALSE(.auth$auth_active)) {
    return(NULL)
  }
  if (!drive_has_token()) {
    drive_auth()
  }
  httr::config(token = .auth$cred)
}

#' Is there a token on hand?
#'
#' Reports whether googledrive has stored a token, ready for use in downstream
#' requests. Exists mostly for protecting examples that won't work in the
#' absence of a token.
#'
#' @return Logical.
#' @export
#'
#' @examples
#' drive_has_token()
drive_has_token <- function() {
  inherits(.auth$cred, "Token2.0")
}

#' View or edit auth config
#'
#' @eval gargle:::PREFIX_auth_config_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_config_params_except_key(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_config_params_key(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_config_return_with_key(gargle_lookup_table)
#'
#' @family auth functions
#' @export
#' @examples
#' ## this will print current config
#' drive_auth_config()
#'
#' if (require(httr)) {
#'   ## bring your own app via client id (aka key) and secret
#'   google_app <- httr::oauth_app(
#'     "my-awesome-google-api-wrapping-package",
#'     key = "123456789.apps.googleusercontent.com",
#'     secret = "abcdefghijklmnopqrstuvwxyz"
#'   )
#'   drive_auth_config(app = google_app)
#' }
#'
#' \dontrun{
#' ## bring your own app via JSON downloaded from Google Developers Console
#' drive_auth_config(
#'   path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
#' )
#' }
drive_auth_config <- function(app = NULL,
                              path = NULL,
                              api_key = NULL) {
  stopifnot(is.null(app) || inherits(app, "oauth_app"))
  stopifnot(is.null(path) || is_string(path))
  stopifnot(is.null(api_key) || is_string(api_key))

  if (!is.null(app) && !is.null(path)) {
    stop_glue("Don't provide both 'app' and 'path'. Pick one.")
  }

  if (is.null(app) && !is.null(path)) {
    app <- gargle::oauth_app_from_json(path)
  }
  if (!is.null(app)) {
    .auth$set_app(app)
  }

  if (!is.null(api_key)) {
    .auth$set_api_key(api_key)
  }

  .auth
}

#' @export
#' @rdname drive_auth_config
drive_api_key <- function() .auth$api_key

#' @export
#' @rdname drive_auth_config
drive_oauth_app <- function() .auth$app
