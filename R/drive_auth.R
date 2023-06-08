# This file is the interface between googledrive and the
# auth functionality in gargle.

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
drive_auth <- function(email = gargle::gargle_oauth_email(),
                       path = NULL, subject = NULL,
                       scopes = "drive",
                       cache = gargle::gargle_oauth_cache(),
                       use_oob = gargle::gargle_oob_default(),
                       token = NULL) {
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
drive_auth_internal <- function(account = c("docs", "testing"),
                                scopes = NULL) {
  account <- match.arg(account)
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
