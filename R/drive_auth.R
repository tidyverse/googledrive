## This file is the interface between googledrive and the
## auth functionality in gargle.

# Initialization happens in .onLoad()
.auth <- NULL

## The roxygen comments for these functions are mostly generated from data
## in this list and template text maintained in gargle.
gargle_lookup_table <- list(
  PACKAGE     = "googledrive",
  YOUR_STUFF  = "your Drive files",
  PRODUCT     = "Google Drive",
  API         = "Drive API",
  PREFIX      = "drive"
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
#' # load/refresh existing credentials, if available
#' # otherwise, go to browser for authentication and authorization
#' drive_auth()
#'
#' # see user associated with current token
#' drive_user()
#'
#' # force use of a token associated with a specific email
#' drive_auth(email = "jenny@example.com")
#' drive_user()
#'
#' # force the OAuth web dance
#' drive_auth(email = NA)
#'
#' # use a 'read only' scope, so it's impossible to edit or delete files
#' drive_auth(
#'   scopes = "https://www.googleapis.com/auth/drive.readonly"
#' )
#'
#' # use a service account token
#' drive_auth(path = "foofy-83ee9e7c9c48.json")
#' }
drive_auth <- function(email = gargle::gargle_oauth_email(),
                       path = NULL,
                       scopes = "https://www.googleapis.com/auth/drive",
                       cache = gargle::gargle_oauth_cache(),
                       use_oob = gargle::gargle_oob_default(),
                       token = NULL) {
  gargle::check_is_service_account(path, hint = "drive_auth_configure")
  env_unbind(.googledrive, "root_folder")

  cred <- gargle::token_fetch(
    scopes = scopes,
    client = drive_oauth_client() %||% gargle::tidyverse_client(),
    email = email,
    path = path,
    package = "googledrive",
    cache = cache,
    use_oob = use_oob,
    token = token
  )
  if (!inherits(cred, "Token2.0")) {
    drive_abort(c(
      "Can't get Google credentials.",
      "i" = "Are you running {.pkg googledrive} in a non-interactive session? \\
             Consider:",
      "*" = "Call {.fun drive_deauth} to prevent the attempt to get credentials.",
      "*" = "Call {.fun drive_auth} directly with all necessary specifics.",
      "i" = "See gargle's \"Non-interactive auth\" vignette for more details:",
      "i" = "{.url https://gargle.r-lib.org/articles/non-interactive-auth.html}"
    ))
  }
  .auth$set_cred(cred)
  .auth$set_auth_active(TRUE)

  invisible()
}

#' Suspend authorization
#'
#' @eval gargle:::PREFIX_deauth_description_with_api_key(gargle_lookup_table)
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
  env_unbind(.googledrive, "root_folder")
  invisible()
}

#' Produce configured token
#'
#' @eval gargle:::PREFIX_token_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_token_return()
#'
#' @family low-level API functions
#' @export
#' @examplesIf drive_has_token()
#' req <- request_generate(
#'   "drive.files.get",
#'   list(fileId = "abc"),
#'   token = drive_token()
#' )
#' req
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
#' @eval gargle:::PREFIX_has_token_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_has_token_return()
#'
#' @family low-level API functions
#' @export
#'
#' @examples
#' drive_has_token()
drive_has_token <- function() {
  inherits(.auth$cred, "Token2.0")
}

#' Edit and view auth configuration
#'
#' @eval gargle:::PREFIX_auth_configure_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_configure_params()
#' @eval gargle:::PREFIX_auth_configure_return(gargle_lookup_table)
#'
#' @family auth functions
#' @export
#' @examples
#' # see and store the current user-configured OAuth client (probaby `NULL`)
#' (original_client <- drive_oauth_client())
#'
#' # see and store the current user-configured API key (probaby `NULL`)
#' (original_api_key <- drive_api_key())
#'
#' # the preferred way to configure your own client is via a JSON file
#' # downloaded from Google Developers Console
#' # this example JSON is indicative, but fake
#' path_to_json <- system.file(
#'   "extdata", "data", "client_secret_123.googleusercontent.com.json",
#'   package = "googledrive"
#' )
#' drive_auth_configure(path = path_to_json)
#'
#' # this is also obviously a fake API key
#' drive_auth_configure(api_key = "the_key_I_got_for_a_google_API")
#'
#' # confirm the changes
#' drive_oauth_client()
#' drive_api_key()
#'
#' # restore original auth config
#' drive_auth_configure(client = original_client, api_key = original_api_key)
drive_auth_configure <- function(client, path, api_key, app = deprecated()) {
  if (lifecycle::is_present(app)) {
    lifecycle::deprecate_warn(
      "2.1.0",
      "drive_auth_configure(app)",
      "drive_auth_configure(client)"
    )
    drive_auth_configure(client = app, path = path, api_key = api_key)
  }

  if (!missing(client) && !missing(path)) {
    drive_abort("Must supply exactly one of {.arg client} or {.arg path}, not both")
  }
  stopifnot(missing(api_key) || is.null(api_key) || is_string(api_key))

  if (!missing(path)) {
    stopifnot(is_string(path))
    client <- gargle::gargle_oauth_client_from_json(path)
  }
  stopifnot(missing(client) || is.null(client) || inherits(client, "gargle_oauth_client"))

  if (!missing(client) || !missing(path)) {
    .auth$set_client(client)
  }

  if (!missing(api_key)) {
    .auth$set_api_key(api_key)
  }

  invisible(.auth)
}

#' @export
#' @rdname drive_auth_configure
drive_api_key <- function() {
  .auth$api_key
}

#' @export
#' @rdname drive_auth_configure
drive_oauth_client <- function() {
  .auth$client
}

# unexported helpers that are nice for internal use ----
drive_auth_internal <- function(account = c("docs", "testing"),
                                scopes = NULL) {
  account <- match.arg(account)
  can_decrypt <- gargle:::secret_can_decrypt("googledrive")
  online <- !is.null(curl::nslookup("drive.googleapis.com", error = FALSE))
  if (!can_decrypt || !online) {
    drive_abort(
      message = c(
        "Auth unsuccessful:",
        if (!can_decrypt) {
          c("x" = "Can't decrypt the {.field {account}} service account token.")
        },
        if (!online) {
          c("x" = "We don't appear to be online. Or maybe the Drive API is down?")
        }
      ),
      class = "googledrive_auth_internal_error",
      can_decrypt = can_decrypt, online = online
    )
  }

  if (!is_interactive()) local_drive_quiet()
  filename <- glue("googledrive-{account}.json")
  # TODO: revisit when I do PKG_scopes()
  # https://github.com/r-lib/gargle/issues/103
  scopes <- scopes %||% "https://www.googleapis.com/auth/drive"
  json <- gargle:::secret_read("googledrive", filename)
  drive_auth(scopes = scopes, path = rawToChar(json))
  print(drive_user())
  invisible(TRUE)
}

drive_auth_docs <- function(scopes = NULL) {
  drive_auth_internal("docs", scopes = scopes)
}

drive_auth_testing <- function(scopes = NULL) {
  drive_auth_internal("testing", scopes = scopes)
}

local_deauth <- function(env = parent.frame()) {
  original_cred <- .auth$get_cred()
  original_auth_active <- .auth$auth_active
  drive_bullets(c("i" = "Going into deauthorized state."))
  withr::defer(
    drive_bullets(c("i" = "Restoring previous auth state.")),
    envir = env
  )
  withr::defer(
    {
      .auth$set_cred(original_cred)
      .auth$set_auth_active(original_auth_active)
    },
    envir = env
  )
  drive_deauth()
}
