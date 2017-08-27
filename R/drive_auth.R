## we will outsource a great deal of this to gargle, but not in time for
## the first CRAN release of googledrive
## https://github.com/r-lib/gargle

## current auth code is a mashup adapted from googlesheets, bigrquery, gmailr
## https://github.com/jennybc/googlesheets/blob/master/R/gs_auth.R
## https://github.com/rstats-db/bigrquery/blob/master/R/auth.r
## https://github.com/jimhester/gmailr/blob/master/R/gmailr.R



#' Authorize googledrive
#'
#' Authorize googledrive to view and manage your Drive files. By default, you
#' are directed to a web browser, asked to sign in to your Google account,
#' and to grant googledrive (the tidyverse, actually) permission to operate on
#' your behalf with Google Drive. By default, these user credentials are cached
#' in a file named `.httr-oauth` in the current working directory, from where
#' they can be automatically refreshed, as necessary.
#'
#' Most users, most of the time, do not need to call `drive_auth()` explicitly
#' -- it is triggered by the first action that requires authorization. Even when
#' called, the default arguments will often suffice. However, when necessary,
#' this function allows the user to
#'   * force the adoption of a new token, via `reset = TRUE`
#'   * retrieve current token, e.g., for storage to an `.rds` file
#'   * put a pre-existing OAuth or service account token into force
#'   * prevent the caching of new, interactively-obtained credentials in
#'   `.httr-oauth`
#'
#' For even deeper control over auth, use [drive_auth_config()] to use your own
#' oauth app or API key. [drive_auth_config()] also allows you to
#' deactivate auth, sending only an API key in requests, which works if you
#' only need to access public data.
#'
#' @seealso More detail is available from
#' [Using OAuth 2.0 for Installed Applications](https://developers.google.com/identity/protocols/OAuth2InstalledApp)
#'
#' @param oauth_token Optional; path to an `.rds` file with a previously stored
#'   oauth token.
#' @param service_token Optional; a JSON string, URL, or path, giving or
#'   pointing to the service token file.
#' @param reset Logical, defaults to `FALSE`. Set to `TRUE` if you want to
#'   forget any token previously used in this session and start afresh. Disables
#'   the `.httr-oauth` file in current working directory by renaming to
#'   `.httr-oauth-SUSPENDED`.
#' @inheritParams httr::oauth2.0_token
#'
#' @template verbose
#' @family auth functions
#' @export
#'
#' @examples
#' \dontrun{
#' ## load/refresh existing credentials, if available
#' ## otherwise, go to browser for authentication and authorization
#' drive_auth()
#'
#' ## force a new oauth token to be obtained
#' drive_auth(reset = TRUE)
#'
#' ## store token in an object and then to file
#' ttt <- drive_auth()
#' saveRDS(ttt, "ttt.rds")
#'
#' ## load a pre-existing token
#' drive_auth("ttt.rds") # from .rds file
#'
#' ## use a service account token
#' drive_auth(service_token = "foofy-83ee9e7c9c48.json")
#' }
drive_auth <- function(oauth_token = NULL,
                       service_token = NULL,
                       reset = FALSE,
                       cache = getOption("httr_oauth_cache"),
                       use_oob = getOption("httr_oob_default"),
                       verbose = TRUE) {

  if (reset) {
    drive_deauth(clear_cache = TRUE, verbose = verbose)
  }

  if (is.null(oauth_token)) {
    if (is.null(service_token)) {
      set_oauth2.0_cred(app = oauth_app(), cache = cache, use_oob = use_oob)
    } else {
      stopifnot(is_string(service_token))
      set_service_token(service_token)
    }
    return(invisible(access_cred()))
  }

  stopifnot(is_string(oauth_token))
  drive_token <- tryCatch(
    readRDS(oauth_token),
    error = function(e) {
      stop_glue("\nCannot read token from alleged .rds file:\n  * {token}")
    }
  )
  if (!is_legit_token(drive_token, verbose = TRUE)) {
    stop_glue("\nFile does not contain a proper oauth token:\n  * {token}")
  }
  invisible(set_access_cred(drive_token))
}

#' Suspend authorization.
#'
#' Suspend googledrive's authorization to place requests to the Drive API on
#' behalf of the authenticated user.
#'
#' @param clear_cache logical indicating whether to disable the
#'   `.httr-oauth` file in working directory, if such exists, by renaming
#'   to `.httr-oauth-SUSPENDED`
#' @template verbose
#'
#' @export
#' @family auth functions
#' @examples
#' \dontrun{
#' drive_deauth()
#' }
drive_deauth <- function(clear_cache = TRUE, verbose = TRUE) {

  if (clear_cache && file.exists(".httr-oauth")) {
    if (verbose) {
      message("Disabling .httr-oauth by renaming to .httr-oauth-SUSPENDED")
    }
    file.rename(".httr-oauth", ".httr-oauth-SUSPENDED")
  }

  if (token_available(verbose = FALSE)) {
    if (verbose) {
      message("Removing google token stashed internally in 'googledrive'.")
    }
    reset_access_cred()
  } else {
    message("No token currently in force.")
  }

  invisible(NULL)

}

#' View or set auth config
#'
#' @description This function gives advanced users more control over auth.
#' Whereas [drive_auth()] gives control over tokens, `drive_auth_config()`
#' gives control of:
#'   * The googledrive auth state. The default is active, meaning all requests
#'   are sent with a token and, if one is not already loaded, OAuth flow is
#'   initiated. It is possible, however, to place unauthorizeded requests to
#'   the Drive API, as long as you are accessing public resources. Set `active`
#'   to `FALSE` to enter this state and never send a token.
#'   * The OAuth app. If you want to use your own app, setup a new project in
#'   [Google Developers Console](https://console.developers.google.com). Follow
#'   the instructions in
#'   [OAuth 2.0 for Mobile & Desktop Apps](https://developers.google.com/identity/protocols/OAuth2InstalledApp)
#'   to obtain you own client ID and secret. Provide these to
#'   [pkg::func(httr::oauth_app)].
#'   * The API key. If googledrive auth is deactivated (see above), all requests
#'   will be sent with an API key. If you want to provide your own, setup a
#'   project as described above and follow the instructions in
#'   [Setting up API keys](https://support.google.com/googleapi/answer/6158862).
#'
#' @param active Logical. `TRUE` means a token will be sent. `FALSE` means it
#'   will not.
#' @param app OAuth app. Defaults to tidyverse app that ships with googledrive.
#' @param api_key API key. Defaults to key that ships with googledrive.
#'   Necessary in order to make unauthorized "token-free" requests for public
#'   resources.
#' @template verbose
#'
#' @family auth functions
#' @return A list of class `auth_config`, with the current auth configuration.
#' @export
#' @examples
#' drive_auth_config()
drive_auth_config <- function(active = TRUE,
                              app = NULL,
                              api_key = NULL,
                              verbose = TRUE) {
  stopifnot(is.logical(active))
  if (!is.null(app)) {
    stopifnot(inherits(app, "oauth_app"))
  }
  if (!is.null(api_key)) {
    stopifnot(is.character(api_key), length(api_key) == 1)
  }

  set_auth_active(isTRUE(active))
  set_oauth_app(app %||% .state[["tidyverse_app"]])
  set_api_key(api_key %||% .state[["tidyverse_api_key"]])

  structure(
    list(
      active = auth_active(),
      oauth_app_name = oauth_app()[['appname']],
      api_key = drive_api_key(),
      token = access_cred()
    ),
    class = c("auth_config", "list")
  )
}

#' @export
print.auth_config <- function(x, ...) {
  cat(
      glue("googledrive auth state: ",
           "{if (x[['active']]) 'active' else 'inactive'}\n",
           "oauth app: ",
           "{x[['oauth_app_name']]}\n",
           "API key: ",
           "{if (is.null(x[['api_key']])) 'unset' else 'set'}\n",
           "token: ",
           "{if (is.null(x[['token']])) 'not loaded' else 'loaded'}"
    ),
    sep = ""
  )
  invisible(x)
}

#' Produce Google token
#'
#' For internal use or for those programming around the Drive API. Produces a
#' token prepared for use with [generate_request()] and [build_request()]. Most
#' users do not need to handle tokens "by hand" or, even if they need some
#' control, [drive_auth()] is what they need. If there is no current token,
#' [drive_auth()] is called to either load from cache or initiate OAuth2.0 flow.
#' If auth has been deactivated via [drive_auth_config()], `drive_token()`
#' returns `NULL`.
#'
#' @template verbose
#'
#' @return a `request` object (an S3 class provided by [httr][httr::httr])
#' @export
#' @family low-level API functions
#' @examples
#' \dontrun{
#' req <- generate_request(
#'   "drive.files.get",
#'   list(fileId = "abc"),
#'   token = drive_token()
#' )
#' req
#' }
drive_token <- function(verbose = FALSE) {
  if (!auth_active()) {
    return(NULL)
  }
  if (!token_available(verbose = verbose)) {
    drive_auth(verbose = verbose)
  }
  httr::config(token = access_cred())
}

## Reveals the actual access token, suitable for use with curl.
access_token <- function() {
  if (!token_available(verbose = TRUE)) return(NULL)
  .state$cred$credentials$access_token
}

set_auth_active <- function(value) {
  .state$active <- value
}

auth_active <- function() {
  .state$active
}

set_access_cred <- function(value) {
  .state$cred <- value
}

reset_access_cred <- function() {
  set_access_cred(NULL)
}

access_cred <- function() {
  .state$cred
}

set_oauth2.0_cred <- function(app = NULL, cache = NULL, use_oob = NULL) {
  cred <- httr::oauth2.0_token(
    endpoint = httr::oauth_endpoints("google"),
    app = app %||% oauth_app(),
    scope = "https://www.googleapis.com/auth/drive",
    cache = cache,
    use_oob = use_oob
  )
  stopifnot(is_legit_token(cred, verbose = TRUE))
  set_access_cred(cred)
}

set_service_token <- function(service_token) {
  service_token <- jsonlite::fromJSON(service_token)
  cred <- httr::oauth_service_token(
    endpoint = httr::oauth_endpoints("google"),
    service_token,
    scope = "https://www.googleapis.com/auth/drive"
  )
  set_access_cred(cred)
}

set_api_key <- function(value) {
  .state[["api_key"]] <- value
}

#' Retrieve API key
#'
#' Retrieves the pre-configured API key. Learn more in Google's document
#' [Credentials, access, security, and
#' identity](https://support.google.com/googleapi/answer/6158857?hl=en&ref_topic=7013279).
#' By default, this API key is initialized to one that ships with googledrive.
#' But the user can store their own key via [drive_auth_config()], i.e.
#' overwrite the default.
#'
#' @return A Google API key.
#' @export
#' @examples
#' drive_api_key()
#'
#' \dontrun{
#' drive_auth_config(api_key = "123")
#' drive_api_key()
#' }
drive_api_key <- function() {
  .state[["api_key"]]
}

set_oauth_app <- function(value) {
  .state[["oauth_app"]] <- value
}

oauth_app <- function() {
  .state[["oauth_app"]]
}

#' Check token availability
#'
#' Check if a token is available in googledrive internal `.state` environment.
#'
#' @return logical
#'
#' @keywords internal
token_available <- function(verbose = TRUE) {
  if (is.null(access_cred())) {
    if (verbose) {
      if (file.exists(".httr-oauth")) {
        message("A .httr-oauth file exists in current working ",
                "directory.\nWhen/if needed, the credentials cached in ",
                ".httr-oauth will be used for this session.\nOr run drive_auth() ",
                "for explicit authentication and authorization.")
      } else {
        message("No .httr-oauth file exists in current working directory.\n",
                "When/if needed, 'googledrive' will initiate authentication ",
                "and authorization.\nOr run drive_auth() to trigger this ",
                "explicitly.")
      }
    }
    return(FALSE)
  }
  TRUE
}

#' Check that token appears to be legitimate
#'
#' @keywords internal
is_legit_token <- function(x, verbose = FALSE) {

  if (!inherits(x, "Token2.0")) {
    if (verbose) message("Not a Token2.0 object.")
    return(FALSE)
  }

  if ("invalid_client" %in% unlist(x$credentials)) {
    # shouldn't happen if id and secret are good
    if (verbose) {
      message("Authorization error. Please check client_id and client_secret.")
    }
    return(FALSE)
  }

  if ("invalid_request" %in% unlist(x$credentials)) {
    # in past, this could happen if user clicks "Cancel" or "Deny" instead of
    # "Accept" when OAuth2 flow kicks to browser ... but httr now catches this
    if (verbose) message("Authorization error. No access token obtained.")
    return(FALSE)
  }

  TRUE

}
