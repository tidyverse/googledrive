# This file is the interface between googledrive and the
# auth functionality in gargle.

# Initialization happens in .onLoad()
.auth <- NULL

## The roxygen comments for these functions are mostly generated from data
## in this list and template text maintained in gargle.
gargle_lookup_table <- list(
  PACKAGE = "googledrive",
  YOUR_STUFF = "your Drive files",
  PRODUCT = "Google Drive",
  API = "Drive API",
  PREFIX = "drive"
)

#' Authorize googledrive
#'
#' @eval gargle:::PREFIX_auth_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_details(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_params()
#'
#' @param scopes One or more API scopes. Each scope can be specified in full or,
#'   for Drive API-specific scopes, in an abbreviated form that is recognized by
#'   [drive_scopes()]:
#'   * "drive" = "https://www.googleapis.com/auth/drive" (the default)
#'   * "full" = "https://www.googleapis.com/auth/drive" (same as "drive")
#'   * "drive.readonly" = "https://www.googleapis.com/auth/drive.readonly"
#'   * "drive.file" = "https://www.googleapis.com/auth/drive.file"
#'   * "drive.appdata" = "https://www.googleapis.com/auth/drive.appdata"
#'   * "drive.metadata" = "https://www.googleapis.com/auth/drive.metadata"
#'   * "drive.metadata.readonly" = "https://www.googleapis.com/auth/drive.metadata.readonly"
#'   * "drive.photos.readonly" = "https://www.googleapis.com/auth/drive.photos.readonly"
#'   * "drive.scripts" = "https://www.googleapis.com/auth/drive.scripts
#'
#'   See <https://developers.google.com/drive/api/guides/api-specific-auth> for
#'   details on the permissions for each scope.
#'
#' @family auth functions
#' @export
#'
#' @examplesIf rlang::is_interactive()
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
#' drive_auth(scopes = "drive.readonly")
#'
#' # use a service account token
#' drive_auth(path = "foofy-83ee9e7c9c48.json")
drive_auth <- function(
  email = gargle::gargle_oauth_email(),
  path = NULL,
  subject = NULL,
  scopes = "drive",
  cache = gargle::gargle_oauth_cache(),
  use_oob = gargle::gargle_oob_default(),
  token = NULL
) {
  gargle::check_is_service_account(path, hint = "drive_auth_configure")
  scopes <- drive_scopes(scopes)
  env_unbind(.googledrive, "root_folder")

  # If `token` is not `NULL`, it's much better to error noisily now, before
  # getting silently swallowed by `token_fetch()`.
  force(token)

  cred <- gargle::token_fetch(
    scopes = scopes,
    client = drive_oauth_client() %||% gargle::tidyverse_client(),
    email = email,
    path = path,
    subject = subject,
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
#' @examplesIf rlang::is_interactive()
#' drive_deauth()
#' drive_user()
#'
#' # in a deauth'ed state, we can still get metadata on a world-readable file
#' public_file <- drive_example_remote("chicken.csv")
#' public_file
#' # we can still download it too
#' drive_download(public_file)
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
#' # see and store the current user-configured OAuth client (probably `NULL`)
#' (original_client <- drive_oauth_client())
#'
#' # see and store the current user-configured API key (probably `NULL`)
#' (original_api_key <- drive_api_key())
#'
#' # the preferred way to configure your own client is via a JSON file
#' # downloaded from Google Developers Console
#' # this example JSON is indicative, but fake
#' path_to_json <- system.file(
#'   "extdata", "client_secret_installed.googleusercontent.com.json",
#'   package = "gargle"
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
drive_auth_configure <- function(client, path, api_key) {
  if (!missing(client) && !missing(path)) {
    drive_abort(
      "Must supply exactly one of {.arg client} or {.arg path}, not both"
    )
  }
  if (!missing(api_key)) {
    check_string(api_key, allow_null = TRUE)
  }

  if (!missing(path)) {
    check_string(path)
    client <- gargle::gargle_oauth_client_from_json(path)
  }
  if (
    !missing(client) &&
      !is.null(client) &&
      !inherits(client, "gargle_oauth_client")
  ) {
    stop_input_type(client, "a <gargle_oauth_client>", allow_null = TRUE)
  }

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

# drive_token_write / drive_token_read() ----

#' Write/read a googledrive user token
#'
#' @description `r lifecycle::badge("experimental")`
#'

#' This pair of functions writes an OAuth2 user token to file and reads it back
#' in. This is rarely necessary when working in your primary, interactive
#' computing environment. In that setting, it is recommended to lean into the
#' automatic token caching built-in to googledrive / gargle. However, when
#' preparing a user token for use elsewhere, such as in CI or in a deployed data
#' product, it can be useful to take the full control granted by
#' `drive_token_write()` and `drive_token_read()`.
#'
#' Below is an outline of the intended workflow, but you will need to fill in
#' particulars, such as filepaths and environment variables:
#' * Do auth in your primary, interactive environment as the target user, with
#'   the desired OAuth client and scopes.
#'   ``` r
#'   drive_auth("jane@example.com", cache = FALSE)
#'   ```
#' * Confirm you are logged in as the intended user:
#'   ``` r
#'   drive_user()
#'   ```
#' * Write the current token to file:
#'   ``` r
#'   drive_token_write(
#'     path = "path/to/googledrive-token.rds",
#'     key = "GOOGLEDRIVE_TOKEN_KEY"
#'   )
#'   ```
#' * In the deployed, non-interactive setting, read the token from file and
#'   tell googledrive to use it:
#'   ``` r
#'   drive_auth(token = drive_token_read(
#'     path = "path/to/googledrive-token.rds",
#'     key = "GOOGLEDRIVE_TOKEN_KEY"
#'   ))
#'   ```
#'
#' @section Security:

#' `drive_token_write()` and `drive_token_read()` have a more security-oriented
#' implementation than the default token caching strategy. OAuth2 user tokens
#' are somewhat opaque by definition, because they aren't written to file in a
#' particularly transparent format. However, `drive_token_write()` always
#' applies some additional obfuscation to make such credentials even more
#' resilient against scraping by an automated tool. However, a knowledgeable R
#' programmer could decode the credential with some effort. The default
#' behaviour of `drive_token_write()` (called without `key`) is suitable for
#' tokens stored in a relatively secure place, such as on Posit Connect within
#' your organization.
#'
#' To prepare a stored credential for exposure in a more public setting, such as
#' on GitHub or CRAN, you must actually encrypt it, using a `key` known only to
#' you. You must make the encryption `key` available via a secure environment
#' variable in any setting where you wish to decrypt and use the token, such as
#' on GitHub Actions.
#'
#' @inheritParams drive_auth
#' @param path The path to write to (`drive_token_write()`) or to read from
#'   (`drive_token_read()`).
#' @param key Encryption key, as implemented by httr2's [secret
#'   functions](https://httr2.r-lib.org/reference/secrets.html). If absent, a
#'   built-in `key` is used. If supplied, the `key` should usually be the name
#'   of an environment variable whose value was generated with
#'   `gargle::secret_make_key()` (which is a copy of
#'   `httr2::secret_make_key()`). The `key` argument of `drive_token_read()`
#'   must match the `key` used in `drive_token_write()`.
#'
#' @export
drive_token_write <- function(
  token = drive_token(),
  path = "googledrive-token.rds",
  key = NULL
) {
  if (inherits(token, "request")) {
    token <- token$auth_token
  }
  if (!inherits(token, "Token2.0")) {
    stop_input_type(token, "a <Token2.0> or the result of `drive_token()`")
  }
  check_string(path)
  key <- key %||% googledrive_obfuscate_key()

  gargle::secret_write_rds(token, path, key)
}

#' @rdname drive_token_write
#' @export
drive_token_read <- function(path = "googledrive-token.rds", key = NULL) {
  check_string(path)
  if (!file.exists(path)) {
    drive_abort("Can't find token file at {.path {path}}.")
  }
  key <- key %||% googledrive_obfuscate_key()
  gargle::secret_read_rds(path, key)
}

#' Produce scopes specific to the Drive API
#'
#' When called with no arguments, `drive_scopes()` returns a named character vector
#' of scopes associated with the Drive API. If `drive_scopes(scopes =)` is given,
#' an abbreviated entry such as `"drive.readonly"` is expanded to a full scope
#' (`"https://www.googleapis.com/auth/drive.readonly"` in this case).
#' Unrecognized scopes are passed through unchanged.
#'
#' @inheritParams drive_auth
#'
#' @seealso <https://developers.google.com/drive/api/guides/api-specific-auth> for details on
#'   the permissions for each scope.
#' @returns A character vector of scopes.
#' @family auth functions
#' @export
#' @examples
#' drive_scopes("full")
#' drive_scopes("drive.readonly")
#' drive_scopes()
drive_scopes <- function(scopes = NULL) {
  if (is.null(scopes)) {
    drive_api_scopes
  } else {
    resolve_scopes(user_scopes = scopes, package_scopes = drive_api_scopes)
  }
}

drive_api_scopes <- c(
  drive = "https://www.googleapis.com/auth/drive",
  full = "https://www.googleapis.com/auth/drive",
  drive.readonly = "https://www.googleapis.com/auth/drive.readonly",
  drive.file = "https://www.googleapis.com/auth/drive.file",
  drive.appdata = "https://www.googleapis.com/auth/drive.appdata",
  drive.metadata = "https://www.googleapis.com/auth/drive.metadata",
  drive.metadata.readonly = "https://www.googleapis.com/auth/drive.metadata.readonly",
  drive.photos.readonly = "https://www.googleapis.com/auth/drive.photos.readonly",
  drive.scripts = "https://www.googleapis.com/auth/drive.scripts"
)

resolve_scopes <- function(user_scopes, package_scopes) {
  m <- match(user_scopes, names(package_scopes))
  ifelse(is.na(m), user_scopes, package_scopes[m])
}

# unexported helpers that are nice for internal use ----
drive_auth_internal <- function(account = c("docs", "testing"), scopes = NULL) {
  account <- arg_match(account)
  can_decrypt <- gargle::secret_has_key("GOOGLEDRIVE_KEY")
  online <- !is.null(curl::nslookup("drive.googleapis.com", error = FALSE))
  if (!can_decrypt || !online) {
    drive_abort(
      message = c(
        "Auth unsuccessful:",
        if (!can_decrypt) {
          c("x" = "Can't decrypt the {.field {account}} service account token.")
        },
        if (!online) {
          c(
            "x" = "We don't appear to be online. Or maybe the Drive API is down?"
          )
        }
      ),
      class = "googledrive_auth_internal_error",
      can_decrypt = can_decrypt,
      online = online
    )
  }

  if (!is_interactive()) {
    local_drive_quiet()
  }
  filename <- glue("googledrive-{account}.json")
  # TODO: revisit when I do PKG_scopes()
  # https://github.com/r-lib/gargle/issues/103
  scopes <- scopes %||% "https://www.googleapis.com/auth/drive"
  drive_auth(
    scopes = scopes,
    path = gargle::secret_decrypt_json(
      system.file("secret", filename, package = "googledrive"),
      "GOOGLEDRIVE_KEY"
    )
  )
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
