## This file is the interface between googledrive and the
## auth functionality in gargle.

.auth <- gargle::init_AuthState(
  package     = "googledrive",
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
    app = drive_oauth_app() %||% gargle::tidyverse_app(),
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
  .auth$clear_cred()
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

# TODO(jennybc): update roxygen header below when/if gargle supports
# THING_auth_configure, instead of or in addition to THING_auth_config.

#' Edit and view auth configuration
#'
#' @description
#' These functions give more control over and visibility into the auth
#' configuration than [drive_auth()] does. `drive_auth_configure()` lets the
#' user specify their own:
#' * OAuth app, which is used when obtaining a user token.
#' * API key. If googledrive is deauthorized via [drive_deauth()], all requests
#'    are sent with an API key in lieu of a token.
#'
#' See the vignette [How to get your own API
#' credentials](https://gargle.r-lib.org/articles/get-api-credentials.html) for
#' more. If the user does not configure these settings, internal defaults are
#' used.
#'
#' @param app OAuth app, in the sense of [httr::oauth_app()].
# @param path JSON obtained from [Google Developers
#   Console](https://console.developers.google.com), containing a client id
#   (aka key) and secret, in one of the forms supported for the `txt` argument
#   of [jsonlite::fromJSON()] (typically, a file path or JSON string).
#' @inheritParams gargle::oauth_app_from_json
#' @param api_key API key.
#'
#' @return
#' * `drive_auth_configure()`: An object of R6 class [gargle::AuthState],
#'   invisibly.
#' * `drive_oauth_app()`: the current user-configured [httr::oauth_app()].
#' * `drive_api_key()`: the current user-configured API key.
#'
#' @family auth functions
#' @export
#' @examples
#' # see and store the current user-configured OAuth app (probaby `NULL`)
#' (original_app <- drive_oauth_app())
#'
#' # see and store the current user-configured API key (probaby `NULL`)
#' (original_api_key <- drive_api_key())
#'
#' if (require(httr)) {
#'   # bring your own app via client id (aka key) and secret
#'   google_app <- httr::oauth_app(
#'     "my-awesome-google-api-wrapping-package",
#'     key = "123456789.apps.googleusercontent.com",
#'     secret = "abcdefghijklmnopqrstuvwxyz"
#'   )
#'   google_key <- "the-key-I-got-for-a-google-API"
#'   drive_auth_configure(app = google_app, api_key = google_key)
#'
#'   # confirm the changes
#'   drive_oauth_app()
#'   drive_api_key()
#' }
#'
#' \dontrun{
#' ## bring your own app via JSON downloaded from Google Developers Console
#' drive_auth_configure(
#'   path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
#' )
#' }
#'
#' # restore original auth config
#' drive_auth_configure(app = original_app, api_key = original_api_key)
drive_auth_configure <- function(app, path, api_key) {
  if (!missing(app) && !missing(path)) {
    stop("Must supply exactly one of `app` and `path`", call. = FALSE)
  }
  stopifnot(missing(api_key) || is.null(api_key) || is_string(api_key))

  if (!missing(path)) {
    stopifnot(is_string(path))
    app <- gargle::oauth_app_from_json(path)
  }
  stopifnot(missing(app) || is.null(app) || inherits(app, "oauth_app"))

  if (!missing(app) || !missing(path)) {
    .auth$app <- app
  }

  if (!missing(api_key)) {
    .auth$api_key <- api_key
  }

  invisible(.auth)

  # switch to these once this is resolved and released
  # https://github.com/r-lib/gargle/issues/82#issuecomment-502343745
  #.auth$set_app(app)
  #.auth$set_api_key(api_key)
}

#' @export
#' @rdname drive_auth_configure
drive_api_key <- function() .auth$api_key

#' @export
#' @rdname drive_auth_configure
drive_oauth_app <- function() .auth$app
